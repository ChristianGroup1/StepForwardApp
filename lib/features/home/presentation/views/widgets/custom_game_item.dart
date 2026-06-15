import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/preparation_list_service.dart';
import 'package:stepforward/core/services/recently_opened_service.dart';
import 'package:stepforward/core/services/user_favorites_service.dart';

import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_hashtag_list.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_rating_summary_chip.dart';

class CustomGameItem extends StatefulWidget {
  final GameModel gameModel;
  final bool inFavoritesView;
  const CustomGameItem({
    super.key,
    required this.gameModel,
    this.inFavoritesView = false,
  });

  @override
  State<CustomGameItem> createState() => _CustomGameItemState();
}

class _CustomGameItemState extends State<CustomGameItem> {
  late bool _isInPreparationList;

  @override
  void initState() {
    super.initState();
    _isInPreparationList = preparationListService.containsGame(
      widget.gameModel.id,
    );
  }

  Future<void> _togglePreparation() async {
    final isEn = context.isEn;
    if (_isInPreparationList) {
      await preparationListService.removeGame(widget.gameModel.id);
    } else {
      await preparationListService.addGame(widget.gameModel);
    }

    if (!mounted) return;
    setState(() => _isInPreparationList = !_isInPreparationList);

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final snackBarController = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          _isInPreparationList
              ? (isEn ? 'Added to preparation' : 'تمت الإضافة للتحضير')
              : (isEn ? 'Removed from preparation' : 'تمت الإزالة من التحضير'),
        ),
        action: SnackBarAction(
          label: isEn ? 'Open' : 'فتح',
          onPressed: () => context.pushNamed(Routes.preparationChecklistView),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), snackBarController.close);
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = widget.gameModel;
    final inFavoritesView = widget.inFavoritesView;

    return GestureDetector(
      onTap: () {
        recentlyOpenedService.addGame(gameModel);
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
              height: isDeviceInPortrait(context)
                  ? MediaQuery.sizeOf(context).height * 0.12
                  : MediaQuery.sizeOf(context).height * 0.5,
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
                      Expanded(
                        child: Text(
                          gameModel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.bold16.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
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
                  GameRatingSummaryChip(gameId: gameModel.id, compact: true),
                  verticalSpace(8),
                  GameHashTagsList(tags: gameModel.tags),
                  verticalSpace(8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton.icon(
                      onPressed: _togglePreparation,
                      icon: Icon(
                        _isInPreparationList
                            ? Icons.playlist_remove_rounded
                            : Icons.playlist_add_check_rounded,
                        size: 18,
                      ),
                      label: Text(
                        _isInPreparationList
                            ? (context.isEn ? 'Remove' : 'إزالة من التحضير')
                            : (context.isEn ? 'Prepare' : 'أضف للتحضير'),
                      ),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(
                          color: AppColors.primaryColor.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
