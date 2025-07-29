import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_sliver_app_bar.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_hashtag_list.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';

class GameDetailsViewBody extends StatefulWidget {
  final GameModel game;

  const GameDetailsViewBody({super.key, required this.game});

  @override
  State<GameDetailsViewBody> createState() => _GameDetailsViewBodyState();
}

class _GameDetailsViewBodyState extends State<GameDetailsViewBody> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
     AnalyticsService.logScreenView(
      screenName: 'GameDetailsView - ${widget.game.name}',
    );
    final videoId =
        YoutubePlayerController.convertUrlToId(widget.game.videoLink) ?? '';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        enableJavaScript: true,
        playsInline: true,
        strictRelatedVideos: false,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CustomSliverAppBar(widget: widget),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(24),
                const Text("فيديو اللعبة", style: TextStyles.bold19),
                verticalSpace(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
                verticalSpace(24),
                const MyDivider(height: 50),
                const Text("شرح اللعبة", style: TextStyles.bold19),
                verticalSpace(8),
                Text(widget.game.explanation, style: TextStyles.regular16),
                const MyDivider(height: 50),

                if (widget.game.laws.isNotEmpty) ...[
                  const Text("القوانين", style: TextStyles.bold19),
                  verticalSpace(8),
                  Text(widget.game.laws, style: TextStyles.regular16),
                  const MyDivider(height: 50),
                ],

                const Text("الفئة المستهدفة", style: TextStyles.bold19),
                verticalSpace(8),
                Html(data: widget.game.target),
                const MyDivider(height: 50),

                const Text("الأدوات المطلوبة", style: TextStyles.bold19),
                verticalSpace(8),
                Text(widget.game.tools, style: TextStyles.regular16),
                const MyDivider(height: 50),

                const Text("الفئات", style: TextStyles.bold19),
                verticalSpace(8),
                GameHashTagsList(tags: widget.game.tags),

                verticalSpace(32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
