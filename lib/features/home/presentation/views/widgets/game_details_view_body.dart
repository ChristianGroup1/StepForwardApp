import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:stepforward/core/cubits/language_cubit.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_sliver_app_bar.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_hashtag_list.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/generated/l10n.dart';

class GameDetailsViewBody extends StatefulWidget {
  final GameModel game;

  const GameDetailsViewBody({super.key, required this.game});

  @override
  State<GameDetailsViewBody> createState() => _GameDetailsViewBodyState();
}

class _GameDetailsViewBodyState extends State<GameDetailsViewBody> {
  YoutubePlayerController? _controller;

  // Translated content fields
  bool _isTranslating = false;
  String? _translatedName;
  String? _translatedExplanation;
  String? _translatedTools;
  String? _translatedLaws;
  String? _translatedTarget;
  List<String>? _translatedTags;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translateIfNeeded();
  }

  Future<void> _translateIfNeeded() async {
    final isEnglish = context.read<LanguageCubit>().isEnglish;
    if (!isEnglish) return;
    if (_isTranslating || _translatedName != null) return;

    if (mounted) setState(() => _isTranslating = true);

    final textsToTranslate = [
      widget.game.name,
      widget.game.explanation,
      widget.game.tools,
      widget.game.laws,
      widget.game.target,
      ...widget.game.tags,
    ];

    final translated = await OpenAITranslationService.translateListToEnglish(
      textsToTranslate,
    );

    if (!mounted) return;
    const tagOffset = 5;
    setState(() {
      _translatedName = translated[0];
      _translatedExplanation = translated[1];
      _translatedTools = translated[2];
      _translatedLaws = translated[3];
      _translatedTarget = translated[4];
      _translatedTags = translated.sublist(tagOffset);
      _isTranslating = false;
    });
  }

  void _resetTranslations() {
    setState(() {
      _translatedName = null;
      _translatedExplanation = null;
      _translatedTools = null;
      _translatedLaws = null;
      _translatedTarget = null;
      _translatedTags = null;
      _isTranslating = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageCubit, Locale>(
      listener: (context, locale) {
        if (locale.languageCode == 'en') {
          _resetTranslations();
          _translateIfNeeded();
        } else {
          _resetTranslations();
        }
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(
            widget: widget,
            translatedTitle: _translatedName,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isTranslating
                  ? _buildTranslatingIndicator(context)
                  : _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslatingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          verticalSpace(16),
          Text(S.of(context).translating, style: TextStyles.regular16),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isEnglish = context.read<LanguageCubit>().isEnglish;
    final s = S.of(context);

    final explanation = isEnglish
        ? (_translatedExplanation ?? widget.game.explanation)
        : widget.game.explanation;
    final tools = isEnglish
        ? (_translatedTools ?? widget.game.tools)
        : widget.game.tools;
    final laws = isEnglish
        ? (_translatedLaws ?? widget.game.laws)
        : widget.game.laws;
    final target = isEnglish
        ? (_translatedTarget ?? widget.game.target)
        : widget.game.target;
    final tags = isEnglish
        ? (_translatedTags ?? widget.game.tags)
        : widget.game.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(24),
        Text(s.appropriateAge, style: TextStyles.bold19),
        verticalSpace(8),
        GameHashTagsList(tags: tags),
        const MyDivider(height: 50),
        if (_controller != null) ...[
          Text(s.gameVideo, style: TextStyles.bold19),
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

        Text(s.gameExplanation, style: TextStyles.bold19),
        verticalSpace(8),
        Text(explanation, style: TextStyles.regular16),
        const MyDivider(height: 50),

        Text(s.requiredTools, style: TextStyles.bold19),
        verticalSpace(8),
        Text(tools, style: TextStyles.regular16),
        const MyDivider(height: 50),

        if (laws.isNotEmpty) ...[
          Text(s.rules, style: TextStyles.bold19),
          verticalSpace(8),
          Text(laws, style: TextStyles.regular16),
          const MyDivider(height: 50),
        ],

        Text(s.spiritualGoal, style: TextStyles.bold19),
        verticalSpace(8),
        Html(data: target),

        verticalSpace(24),
      ],
    );
  }
}
