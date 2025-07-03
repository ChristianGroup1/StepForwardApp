import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/features/home/data/home_cubit/home_cubit.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_hashtag_list.dart';
import 'package:stepforward/features/home/presentation/views/widgets/tags_list.dart';

class CustomGameItem extends StatelessWidget {
  final GameModel gameModel;
  final List<String> userFavorites;

  const CustomGameItem({
    super.key,
    required this.gameModel,
    required this.userFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorited = userFavorites.contains(gameModel.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: () => context.pushNamed(Routes.gameDetails, arguments: gameModel),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCachedNetworkImageWidget(
              imageUrl: gameModel.coverUrl,
              borderRadius: 16,
              height: 50,
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameModel.name,
                    style: TextStyles.bold16.copyWith(
                      color: AppColors.primaryColor,
                    ),
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
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    context.read<HomeCubit>().changeGameFavoriteState(
                      gameId: gameModel.id,
                    );
                  },
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
