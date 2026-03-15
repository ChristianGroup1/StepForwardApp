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
import 'package:stepforward/features/home/domain/models/game_model.dart';

class GameDetailsViewBody extends StatefulWidget {
  final GameModel game;

  const GameDetailsViewBody({super.key, required this.game});

  @override
  State<GameDetailsViewBody> createState() => _GameDetailsViewBodyState();
}

class _GameDetailsViewBodyState extends State<GameDetailsViewBody> {
  YoutubePlayerController? _controller;

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
      final videoId = YoutubePlayer.convertUrlToId(widget.game.videoLink);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            showLiveFullscreenButton: true,
            enableCaption: false,
          ),
        );
      }
    }

    // If the app is already in English when this page opens, translate immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final locale = context.read<LocaleCubit>().state.languageCode;
        if (locale == 'en') _translateContent();
      }
    });
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

  /// Builds the deep link for this game.
  String get _deepLink => 'stepforward://game/${widget.game.id}';

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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocaleCubit, Locale>(
      listener: (context, locale) {
        if (locale.languageCode == 'en') {
          _translateContent();
        } else {
          // Switching back to Arabic: clear cached translations so they
          // are re-fetched if the user switches to English again.
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
                          if (_controller != null) ...[
                            Text(
                              isEn ? 'Game Video' : 'فيديو اللعبة',
                              style: TextStyles.bold19,
                            ),
                            verticalSpace(8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: YoutubePlayer(
                                controller: _controller!,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: Colors.red,
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
                          Text(
                            displayExplanation,
                            style: TextStyles.regular16,
                          ),
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
