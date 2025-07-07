import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
class GamesSectionHomeView extends StatelessWidget {
     final VoidCallback onNavigateToGamesView;

  const GamesSectionHomeView({
    super.key, required this.onNavigateToGamesView,
  });

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
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.21,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16,
                      ),
                      child: GestureDetector(
                        onTap: () => context.pushNamed(Routes.gameDetails,arguments: state.games[index]),
                        child: Column(
                          children: [
                            CustomCachedNetworkImageWidget(
                              imageUrl: state.games[index].coverUrl,
                              borderRadius: 16,
                              height: MediaQuery.sizeOf(context).height * 0.14,
                              width:
                                    MediaQuery.sizeOf(context).width * 0.22,
                              fit: BoxFit.cover,
                            ),
                            verticalSpace(8),
                            Text(
                              state.games[index].name,
                              style: TextStyles.bold13,
                            ),
                          ],
                        ),
                      ),
                    ),
                    itemCount: state.games.length,
                  ),
                );
              } else if (state is GetGameFailureState) {
                return Text(state.errorMessage);
              } else if (state is GetGamesLoadingState) {
                return const CustomAnimatedLoadingWidget();
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
