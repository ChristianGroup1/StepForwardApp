import 'package:flutter/material.dart';
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
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (_controller.value.fullScreenOption.enabled) {
          _controller.exitFullScreen();
        }
      },
      child: YoutubePlayerScaffold(
        controller: _controller,
        builder: (context, player) {
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

                      Text("شرح اللعبة", style: TextStyles.bold19),
                      verticalSpace(8),
                      Text(widget.game.explanation, style: TextStyles.regular16),
                      MyDivider(height: 50),

                      if (widget.game.laws.isNotEmpty) ...[
                        Text("القوانين", style: TextStyles.bold19),
                        verticalSpace(8),
                        Text(widget.game.laws, style: TextStyles.regular16),
                        MyDivider(height: 50),
                      ],

                      Text("الفئة المستهدفة", style: TextStyles.bold19),
                      verticalSpace(8),
                      Text(widget.game.target, style: TextStyles.regular16),
                      MyDivider(height: 50),

                      Text("الأدوات المطلوبة", style: TextStyles.bold19),
                      verticalSpace(8),
                      Text(widget.game.tools, style: TextStyles.regular16),
                      MyDivider(height: 50),

                      Text("الفئات", style: TextStyles.bold19),
                      verticalSpace(8),
                      GameHashTagsList(tags: widget.game.tags),
                      MyDivider(height: 50),

                      Text("فيديو اللعبة", style: TextStyles.bold19),
                      verticalSpace(8),

                      GestureDetector(
                        onDoubleTap: () {
                          _controller.enterFullScreen();
                        },
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AbsorbPointer(
                              child: player, // Interaction blocked unless double tapped
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(32),
                    ],
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
