import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/get_dummy_games.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_game_item.dart';

class FavoritesViewBody extends StatelessWidget {
  const FavoritesViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return BlocConsumer<GamesCubit, GamesState>(
      buildWhen: (previous, current) =>
          current is FetchUserFavoritesSuccessState ||
          current is FetchUserFavoritesFailureState ||
          current is FetchUserFavoritesLoadingState,
      listener: (context, state) {
        if (state is FetchUserFavoritesFailureState) {
          log(state.errorMessage);
          AnalyticsService.logScreenView(screenName: 'FavoritesView');
        }
      },
      builder: (context, state) {
        if (state is FetchUserFavoritesSuccessState) {
          if (state.favorites.isEmpty) {
            return Center(
              child: CustomEmptyWidget(
                title: isEn ? 'No favorite games yet' : 'لا توجد ألعاب مفضلة بعد',
                subtitle: isEn
                    ? 'You can add games to favorites by pressing the add button on the game page.'
                    : 'يمكنك إضافة الألعاب إلى المفضلة من خلال الضغط على زر الإضافة في صفحة اللعبة.',
              ),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) => const MyDivider(),
            itemBuilder: (context, index) => Slidable(
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      context.read<GamesCubit>().removeGameFromFavorites(
                        state.favorites[index].id,
                      );
                      context.read<GamesCubit>().fetchUserFavorites();
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: isEn ? 'Delete' : 'حذف',
                  ),
                ],
              ),
              child: CustomGameItem(
                inFavoritesView: true,
                gameModel: state.favorites[index],
              ),
            ),
            itemCount: state.favorites.length,
          );
        } else if (state is FetchUserFavoritesFailureState) {
          return Center(child: Text(state.errorMessage));
        } else {
          return Skeletonizer(
            child: ListView.builder(
              itemBuilder: (context, index) => CustomGameItem(
                gameModel: getDummyGames(),
                inFavoritesView: true,
              ),
              itemCount: 10,
            ),
          );
        }
      },
    );
  }
}
