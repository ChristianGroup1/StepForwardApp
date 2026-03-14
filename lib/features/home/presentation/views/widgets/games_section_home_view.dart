import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/widgets/custom_show_more_blurred_item.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_home_view_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_loading_home_view_item.dart';

class GamesSectionHomeView extends StatelessWidget {
  final VoidCallback onNavigateToGamesView;

  const GamesSectionHomeView({super.key, required this.onNavigateToGamesView});

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isEn ? 'Games' : 'العاب',
                style: TextStyles.bold16.copyWith(color: AppColors.primaryColor),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onNavigateToGamesView(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEn ? 'More' : 'المزيد',
                    style: TextStyles.semiBold13.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          BlocBuilder<GamesCubit, GamesState>(
            buildWhen: (previous, current) =>
                current is GetGamesSuccessState ||
                current is GetGameFailureState ||
                current is GetGamesLoadingState,
            builder: (context, state) {
              if (state is GetGamesSuccessState) {
                final games = state.games;
                final showMore = games.length > 5;
                final itemCount = showMore ? 6 : games.length;

                return SizedBox(
                  height: isDeviceInPortrait(context)
                      ? MediaQuery.sizeOf(context).height * 0.22
                      : MediaQuery.sizeOf(context).height * 0.55,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (showMore && index == 5) {
                        final blurImageUrl = state.games[5].coverUrl;
                        return GestureDetector(
                          onTap: onNavigateToGamesView,
                          child: CustomShowMoreBlurredItem(blurImageUrl: blurImageUrl),
                        );
                      }
                      final game = games[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12, left: 12, top: 16),
                        child: GestureDetector(
                          onTap: () => context.pushNamed(
                            Routes.gameDetails,
                            arguments: game,
                          ),
                          child: CustomHomeViewItem(
                            imageUrl: game.coverUrl,
                            name: game.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (state is GetGameFailureState) {
                return Text(state.errorMessage);
              } else if (state is GetGamesLoadingState) {
                return const CustomLoadingHomeViewItem();
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
