import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
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
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Row(
            children: [
              Text('العاب', style: TextStyles.bold16),
              Spacer(),
              GestureDetector(
                onTap: () => onNavigateToGamesView(),
                child: Text(
                  'المزيد',
                  style: TextStyles.semiBold13.copyWith(
                    color: Color(0xffA5A5A5),
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
                  height:isDeviceInPortrait(context)? MediaQuery.sizeOf(context).height * 0.22:MediaQuery.sizeOf(context).height * 0.55,
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
                        padding: const EdgeInsets.only(
                          right: 12,left: 12,top: 16
                          
                        ),
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
                return CustomLoadingHomeViewItem();
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

