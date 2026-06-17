import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stepforward/core/cubits/locale_cubit.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/services/game_rating_service.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';
import 'package:stepforward/core/services/preparation_list_service.dart';
import 'package:stepforward/core/services/recently_opened_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/core/widgets/custom_sliver_app_bar.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_hashtag_list.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_rating_summary_chip.dart';
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
  String? _translatedGoalTag;
  List<String>? _translatedTags;

  bool _isTranslating = false;
  bool _translationDone = false;
  List<GameModel> _similarGames = [];
  bool _loadedSimilarGames = false;
  final GameRatingService _ratingService = GameRatingService();
  int _rating = 0;
  double _ratingAverage = 0;
  int _ratingCount = 0;
  bool _isInPreparationList = false;

  @override
  void initState() {
    super.initState();
    _isInPreparationList = preparationListService.containsGame(widget.game.id);
    recentlyOpenedService.addGame(widget.game);
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
        _loadRating();
        _loadSimilarGames();
      }
    });
  }

  Future<void> _loadRating() async {
    final rating = await _ratingService.getRating(widget.game.id);
    final stats = await _loadRatingStats();
    if (mounted) {
      setState(() {
        _rating = rating;
        _ratingAverage = stats.$1;
        _ratingCount = stats.$2;
      });
    }
  }

  Future<(double, int)> _loadRatingStats() async {
    try {
      final gameDoc = await FirebaseFirestore.instance
          .collection(BackendEndpoints.getGames)
          .doc(widget.game.id)
          .get();
      final data = gameDoc.data() ?? {};
      return (
        _doubleFromJson(data['ratingAverage']),
        _intFromJson(data['ratingCount']),
      );
    } catch (_) {
      return (0.0, 0);
    }
  }

  Future<void> _rateGame(int rating) async {
    final isEn = context.isEn;

    AnalyticsService.logEvent(
      name: 'rate_game',
      parameters: {
        'game_id': widget.game.id,
        'game_name': widget.game.name,
        'rating': rating,
      },
    );

    try {
      final synced = await _ratingService.saveRating(
        gameId: widget.game.id,
        rating: rating,
      );
      final stats = await _loadRatingStats();
      if (mounted) {
        setState(() {
          _ratingAverage = stats.$1;
          _ratingCount = stats.$2;
        });
      }
      if (!synced && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn
                  ? 'Rating saved locally, but could not sync online'
                  : 'تم حفظ التقييم محليًا، لكن تعذرت مزامنته',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn
                  ? 'Rating saved locally, but could not sync online'
                  : 'تم حفظ التقييم محليًا، لكن تعذرت مزامنته',
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _rating = rating);
    }
  }

  Future<void> _togglePreparationList(bool isEn) async {
    if (_isInPreparationList) {
      await preparationListService.removeGame(widget.game.id);
    } else {
      await preparationListService.addGame(widget.game);
    }

    if (!mounted) return;

    setState(() => _isInPreparationList = !_isInPreparationList);

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final snackBarController = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          _isInPreparationList
              ? (isEn
                    ? 'Game added to preparation list'
                    : 'تمت إضافة اللعبة لقائمة التحضير')
              : (isEn
                    ? 'Game removed from preparation list'
                    : 'تمت إزالة اللعبة من قائمة التحضير'),
        ),
        action: SnackBarAction(
          label: isEn ? 'Open' : 'فتح',
          onPressed: () => context.pushNamed(Routes.preparationChecklistView),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), snackBarController.close);
  }

  Future<void> _loadSimilarGames() async {
    if (_loadedSimilarGames) return;
    _loadedSimilarGames = true;

    List<GameModel> games = [];

    try {
      final gamesCubit = context.read<GamesCubit>();
      games = gamesCubit.allGames;
    } catch (_) {
      final result = await getIt.get<HomeRepo>().getGames();
      games = result.getOrElse(() => []);
    }

    final similar = _findSimilarGames(games);
    if (mounted) {
      setState(() => _similarGames = similar);
    }
  }

  List<GameModel> _findSimilarGames(List<GameModel> games) {
    final current = widget.game;
    final currentTargets = current.filterTargets.map(_normalize).toSet();
    final currentTags = current.tags.map(_normalize).toSet();

    final scoredGames =
        games
            .where((game) => game.id != current.id)
            .map((game) {
              var score = 0;
              final sharedTargets = game.filterTargets
                  .map(_normalize)
                  .where((target) => currentTargets.contains(target))
                  .length;
              score += sharedTargets * 3;
              score += game.tags
                  .map(_normalize)
                  .where((tag) => currentTags.contains(tag))
                  .length;
              return MapEntry(game, score);
            })
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return scoredGames.map((entry) => entry.key).take(5).toList();
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
      'goalTag': game.goalTag,
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
        _translatedGoalTag = fields['goalTag'];
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
  /// The website page at this URL attempts to open the app via the
  /// custom scheme `stepforward://game/{id}`, falling back to Google Play if
  /// the app is not installed.
  String get _deepLink => '$kFirebaseHostingBaseUrl/game/${widget.game.id}';

  /// Shares the game via the system share sheet (WhatsApp, Facebook, etc.).
  Future<void> _shareGame(bool isEn) async {
    AnalyticsService.logEvent(
      name: 'share_game',
      parameters: {'game_id': widget.game.id, 'game_name': widget.game.name},
    );

    final gameName = isEn
        ? (_translatedName ?? widget.game.name)
        : widget.game.name;
    final tools = _plainText(
      isEn ? (_translatedTools ?? widget.game.tools) : widget.game.tools,
    );
    final tags =
        (isEn ? (_translatedTags ?? widget.game.tags) : widget.game.tags)
            .where((tag) => tag.trim().isNotEmpty)
            .join(' - ');

    final shareText = isEn
        ? _buildEnglishShareText(gameName: gameName, tags: tags, tools: tools)
        : _buildArabicShareText(gameName: gameName, tags: tags, tools: tools);

    await Share.share(shareText, subject: gameName);
  }

  String _buildArabicShareText({
    required String gameName,
    required String tags,
    required String tools,
  }) {
    return [
      '🎮 لعبة من Step Forward',
      '',
      '📌 الاسم: $gameName',
      if (tags.isNotEmpty) '👥 السن المناسب: $tags',
      if (tools.isNotEmpty) '🧰 الأدوات: $tools',
      '',
      'افتح اللعبة من هنا:',
      _deepLink,
    ].join('\n');
  }

  String _buildEnglishShareText({
    required String gameName,
    required String tags,
    required String tools,
  }) {
    return [
      '🎮 Step Forward Game',
      '',
      '📌 Name: $gameName',
      if (tags.isNotEmpty) '👥 Suitable age: $tags',
      if (tools.isNotEmpty) '🧰 Tools: $tools',
      '',
      'Open the game here:',
      _deepLink,
    ].join('\n');
  }

  String _plainText(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _normalize(String value) => value.trim().toLowerCase();

  int _intFromJson(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _doubleFromJson(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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
          final displayGoalTag = isEn
              ? (_translatedGoalTag ?? widget.game.goalTag)
              : widget.game.goalTag;
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
                    isInPreparationList: _isInPreparationList,
                    onTogglePreparation: () => _togglePreparationList(isEn),
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
                          verticalSpace(10),
                          GameRatingSummaryChip(
                            average: _ratingAverage,
                            count: _ratingCount,
                          ),
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
                            else if (_videoId != null &&
                                _videoController != null)
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
                          if (displayTarget.trim().isNotEmpty ||
                              displayGoalTag.trim().isNotEmpty) ...[
                            Text(
                              isEn ? 'Goal' : 'الهدف',
                              style: TextStyles.bold19,
                            ),
                            verticalSpace(8),
                            if (displayTarget.trim().isNotEmpty)
                              Html(data: displayTarget),
                            if (displayGoalTag.trim().isNotEmpty) ...[
                              verticalSpace(8),
                              _GoalTagChip(label: displayGoalTag),
                            ],
                            const MyDivider(height: 50),
                          ],
                          _GameRatingSection(
                            rating: _rating,
                            isEn: isEn,
                            onRate: _rateGame,
                          ),
                          if (_similarGames.isNotEmpty) ...[
                            const MyDivider(height: 50),
                            Text(
                              isEn ? 'Similar Games' : 'ألعاب مشابهة',
                              style: TextStyles.bold19,
                            ),
                            verticalSpace(12),
                            SizedBox(
                              height: isDeviceInPortrait(context) ? 150 : 260,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _similarGames.length,
                                separatorBuilder: (_, __) =>
                                    horizontalSpace(12),
                                itemBuilder: (context, index) {
                                  return _SimilarGameItem(
                                    game: _similarGames[index],
                                  );
                                },
                              ),
                            ),
                          ],
                          verticalSpace(24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _togglePreparationList(isEn),
                              icon: Icon(
                                _isInPreparationList
                                    ? Icons.playlist_remove_rounded
                                    : Icons.playlist_add_check_rounded,
                              ),
                              label: Text(
                                _isInPreparationList
                                    ? (isEn
                                          ? 'Remove from preparation'
                                          : 'إزالة من التحضير')
                                    : (isEn
                                          ? 'Add to preparation'
                                          : 'أضف للتحضير'),
                              ),
                            ),
                          ),
                          verticalSpace(10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _shareGame(isEn),
                              icon: const Icon(Icons.share_outlined),
                              label: Text(
                                isEn ? 'Share this game' : 'مشاركة اللعبة',
                              ),
                            ),
                          ),
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

class _SimilarGameItem extends StatelessWidget {
  const _SimilarGameItem({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    final width = isDeviceInPortrait(context)
        ? MediaQuery.sizeOf(context).width * 0.34
        : MediaQuery.sizeOf(context).width * 0.18;

    return GestureDetector(
      onTap: () =>
          context.pushReplacementNamed(Routes.gameDetails, arguments: game),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedNetworkImageWidget(
              imageUrl: game.coverUrl,
              borderRadius: 12,
              height: isDeviceInPortrait(context) ? 96 : 190,
              width: width,
              fit: BoxFit.cover,
            ),
            verticalSpace(8),
            Text(
              game.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.bold13.copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTagChip extends StatelessWidget {
  const _GoalTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: TextStyles.semiBold13.copyWith(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

class _GameRatingSection extends StatelessWidget {
  const _GameRatingSection({
    required this.rating,
    required this.isEn,
    required this.onRate,
  });

  final int rating;
  final bool isEn;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.secondaryColor,
                size: 24,
              ),
              horizontalSpace(6),
              Text(
                isEn ? 'Rate this game' : 'قيّم اللعبة',
                style: TextStyles.bold19.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          verticalSpace(8),
          Text(
            rating == 0
                ? (isEn
                      ? 'Tap a star to save your rating'
                      : 'اضغط على النجوم لحفظ تقييمك')
                : (isEn ? 'Your rating: $rating/5' : 'تقييمك: $rating/5'),
            style: TextStyles.regular14.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          verticalSpace(10),
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= rating;

              return IconButton(
                tooltip: '$starValue/5',
                onPressed: () => onRate(starValue),
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.secondaryColor,
                  size: 34,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
