import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stepforward/core/cubits/locale_cubit.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_sliver_app_bar.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_hashtag_list.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:url_launcher/url_launcher.dart';

class GameDetailsViewBody extends StatefulWidget {
  final GameModel game;

  const GameDetailsViewBody({super.key, required this.game});

  @override
  State<GameDetailsViewBody> createState() => _GameDetailsViewBodyState();
}

class _GameDetailsViewBodyState extends State<GameDetailsViewBody> {
  bool _videoPlaybackFailed = false;
  String? _videoId;
  YoutubePlayerController? _videoController;

  // Translated fields (null until translation completes)
  String? _translatedName;
  String? _translatedExplanation;
  String? _translatedTools;
  String? _translatedLaws;
  String? _translatedTarget;
  List<String>? _translatedTags;

  bool _isTranslating = false;
  bool _translationDone = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(
      screenName: 'GameDetailsView - ${widget.game.name}',
    );
    AnalyticsService.logEvent(
      name: 'open_game_details',
      parameters: {'game_id': widget.game.id, 'game_name': widget.game.name},
    );

    if (widget.game.videoLink.isNotEmpty) {
      _initializeVideo();
    }

    // If the app is already in English when this page opens, translate immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final locale = context.read<LocaleCubit>().state.languageCode;
        if (locale == 'en') _translateContent();
      }
    });
  }

  void _initializeVideo() {
    YoutubePlayerController? controller;
    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.game.videoLink);

      if (videoId == null) {
        setState(() => _videoPlaybackFailed = true);
        return;
      }

      controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
        ),
      );

      setState(() {
        _videoId = videoId;
        _videoController = controller;
        _videoPlaybackFailed = false;
      });
    } catch (e) {
      controller?.dispose();
      debugPrint('Error initializing video: $e');
      setState(() => _videoPlaybackFailed = true);
    }
  }

  Future<void> _launchYoutubeVideo() async {
    final url = widget.game.videoLink;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _translateContent() async {
    if (_isTranslating || _translationDone) return;
    setState(() => _isTranslating = true);

    final game = widget.game;
    final fields = await OpenAiTranslationService.translateFields({
      'name': game.name,
      'explanation': game.explanation,
      'tools': game.tools,
      'laws': game.laws,
      'target': game.target,
    });

    final translatedTagsList = await Future.wait(
      game.tags.map(OpenAiTranslationService.translateToEnglish),
    );

    if (mounted) {
      setState(() {
        _translatedName = fields['name'];
        _translatedExplanation = fields['explanation'];
        _translatedTools = fields['tools'];
        _translatedLaws = fields['laws'];
        _translatedTarget = fields['target'];
        _translatedTags = translatedTagsList;
        _isTranslating = false;
        _translationDone = true;
      });
    }
  }

  /// Builds the shareable HTTPS link for this game.
  ///
  /// Using an HTTPS URL ensures the link is recognised as a hyperlink in
  /// messaging apps (WhatsApp, SMS, etc.) and is directly tappable.
  /// The Firebase Hosting page at this URL attempts to open the app via the
  /// custom scheme `stepforward://game/{id}`, falling back to Google Play if
  /// the app is not installed.
  String get _deepLink => '$kFirebaseHostingBaseUrl/game/${widget.game.id}';

  /// Shares the game via the system share sheet (WhatsApp, Facebook, etc.).
  Future<void> _shareGame(bool isEn) async {
    AnalyticsService.logEvent(
      name: 'share_game',
      parameters: {
        'game_id': widget.game.id,
        'game_name': widget.game.name,
      },
    );

    final gameName = isEn
        ? (_translatedName ?? widget.game.name)
        : widget.game.name;

    final shareText = isEn
        ? '🎮 Check out this game on Step Forward!\n\n$gameName\n\n$_deepLink'
        : '🎮 شاهد هذه اللعبة على تطبيق Step Forward!\n\n$gameName\n\n$_deepLink';

    await Share.share(shareText, subject: gameName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocaleCubit, Locale>(
      listener: (context, locale) {
        if (locale.languageCode == 'en') {
          _translateContent();
        } else {
          setState(() => _translationDone = false);
        }
      },
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          final isEn = locale.languageCode == 'en';

          final displayExplanation = isEn
              ? (_translatedExplanation ?? widget.game.explanation)
              : widget.game.explanation;
          final displayTools = isEn
              ? (_translatedTools ?? widget.game.tools)
              : widget.game.tools;
          final displayLaws = isEn
              ? (_translatedLaws ?? widget.game.laws)
              : widget.game.laws;
          final displayTarget = isEn
              ? (_translatedTarget ?? widget.game.target)
              : widget.game.target;
          final displayTags = isEn
              ? (_translatedTags ?? widget.game.tags)
              : widget.game.tags;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  CustomSliverAppBar(
                    widget: widget,
                    onShare: () => _shareGame(isEn),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpace(24),
                          Text(
                            isEn ? 'Suitable Age' : 'السن المناسب ',
                            style: TextStyles.bold19,
                          ),
                          verticalSpace(8),
                          GameHashTagsList(tags: displayTags),
                          const MyDivider(height: 50),
                          if (widget.game.videoLink.isNotEmpty) ...[
                            Text(
                              isEn ? 'Game Video' : 'فيديو اللعبة',
                              style: TextStyles.bold19,
                            ),
                            verticalSpace(8),
                            if (_videoPlaybackFailed)
                              GestureDetector(
                                onTap: _launchYoutubeVideo,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam_off,
                                        size: 48,
                                        color: Colors.red[400],
                                      ),
                                      verticalSpace(12),
                                      Text(
                                        isEn
                                            ? 'Video unavailable'
                                            : 'الفيديو غير متاح',
                                        style: TextStyles.bold16,
                                      ),
                                      verticalSpace(8),
                                      Text(
                                        isEn
                                            ? 'Tap to open on YouTube'
                                            : 'اضغط لفتح على يوتيوب',
                                        style: TextStyles.regular14,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (_videoId != null && _videoController != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: YoutubePlayer(
                                  key: ValueKey(_videoId),
                                  controller: _videoController!,
                                  showVideoProgressIndicator: true,
                                  aspectRatio: 16 / 9,
                                  onReady: () {
                                    debugPrint('Video player is ready');
                                  },
                                  onEnded: (data) {
                                    debugPrint('Video ended');
                                  },
                                ),
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: Colors.black,
                                  height: 220,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            verticalSpace(24),
                            const MyDivider(height: 50),
                          ],
                          Text(
                            isEn ? 'Game Description' : 'شرح اللعبة',
                            style: TextStyles.bold19,
                          ),
                          verticalSpace(8),
                          Text(displayExplanation, style: TextStyles.regular16),
                          const MyDivider(height: 50),
                          Text(
                            isEn ? 'Required Tools' : 'الأدوات المطلوبة',
                            style: TextStyles.bold19,
                          ),
                          verticalSpace(8),
                          Text(displayTools, style: TextStyles.regular16),
                          const MyDivider(height: 50),
                          if (widget.game.laws.isNotEmpty) ...[
                            Text(
                              isEn ? 'Rules' : 'القوانين',
                              style: TextStyles.bold19,
                            ),
                            verticalSpace(8),
                            Text(displayLaws, style: TextStyles.regular16),
                            const MyDivider(height: 50),
                          ],
                          Text(
                            isEn ? 'Spiritual Goal' : 'الهدف الروحي',
                            style: TextStyles.bold19,
                          ),
                          verticalSpace(8),
                          Html(data: displayTarget),
                          verticalSpace(24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_isTranslating)
                const Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Translating…'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
