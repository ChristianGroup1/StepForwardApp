import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/user_favorites_service.dart';

import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_hashtag_list.dart';

class CustomGameItem extends StatelessWidget {
  final GameModel gameModel;

  final bool inFavoritesView;
  const CustomGameItem({
    super.key,
    required this.gameModel,

    this.inFavoritesView = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(Routes.gameDetails, arguments: gameModel);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedNetworkImageWidget(
              imageUrl: gameModel.coverUrl,
              borderRadius: 16,
              height: isDeviceInPortrait(context)? MediaQuery.sizeOf(context).height * 0.12:  MediaQuery.sizeOf(context).height * 0.5,
              width: MediaQuery.sizeOf(context).width * 0.22,
              fit: BoxFit.cover,
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        gameModel.name,
                        style: TextStyles.bold16.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Spacer(),
                      ValueListenableBuilder<List<String>>(
                        valueListenable:
                            userFavoritesService.userFavoritesNotifier,
                        builder: (context, favorites, _) {
                          final isFavorited = favorites.contains(gameModel.id);
                          return IconButton(
                            onPressed: () {
                              if (inFavoritesView) {
                                context
                                    .read<GamesCubit>()
                                    .removeGameFromFavorites(gameModel.id);
                                context.read<GamesCubit>().fetchUserFavorites();
                              } else {
                                context
                                    .read<GamesCubit>()
                                    .changeGameFavoriteState(
                                      gameId: gameModel.id,
                                    );
                              }
                            },
                            icon: inFavoritesView
                                ? const Icon(Icons.delete, color: Colors.red)
                                : Icon(
                                    isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorited
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                  verticalSpace(8),
                  Text(
                    gameModel.explanation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.semiBold13.copyWith(
                      color: const Color(0xff949D9E),
                    ),
                  ),
                  verticalSpace(8),
                  GameHashTagsList(tags: gameModel.tags),
                ],
              ),
            ),

            // Inside CustomGameItem (or any widget showing favorites)
          ],
        ),
      ),
    );
  }
}
