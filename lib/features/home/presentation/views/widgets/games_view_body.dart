import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stepforward/core/helper_functions/get_dummy_games.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/core/widgets/custom_page_app_bar.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_game_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/tags_list.dart';

class GamesViewBody extends StatelessWidget {
  const GamesViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GamesCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding,
        vertical: kVerticalPadding,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: CustomPageAppBar(title: 'الألعاب')),
          SliverToBoxAdapter(child: verticalSpace(24)),
          SliverToBoxAdapter(
            child: SearchTextField(
              controller: context.read<GamesCubit>().searchController,
              onChanged: (value) => context.read<GamesCubit>().searchGames(),
            ),
          ),
          SliverToBoxAdapter(child: verticalSpace(20)),
          SliverToBoxAdapter(
            child: TagsList(
              tags: ['اطفال', 'اعدادي', 'ثانوي', 'جامعة'],
              onTagToggle: cubit.toggleTag,
              selectedTags: cubit.selectedTags,
            ),
          ),
          SliverToBoxAdapter(child: verticalSpace(24)),
          BlocConsumer<GamesCubit, GamesState>(
            buildWhen: (previous, current) =>
                current is GetGamesSuccessState ||
                current is GetGameFailureState ||
                current is GetGamesLoadingState,
            listener: (context, state) {
              if (state is GetGameFailureState) {
                log(state.errorMessage);
              }
              if (state is AddGameToFavoritesSuccessState) {
                showSnackBar(
                  context,
                  text: 'تم اضافة اللعبة للمفضلة',
                  color: Colors.green,
                );
              }
              if (state is RemoveGameFromFavoritesSuccessState) {
                showSnackBar(
                  context,
                  text: 'تم حذف اللعبة من المفضلة',
                  color: Colors.red,
                );
              }
            },
            builder: (context, state) {
              if (state is GetGamesSuccessState) {
                if (state.games.isEmpty) {
                  return SliverToBoxAdapter(
                    child: CustomEmptyWidget(
                      title: 'لا يوجد العاب لهذا السن',
                      subtitle: 'سيتم اضافة العاب اكثر قريبًا  ',
                    ),
                  );
                }
                return SliverList.separated(
                  separatorBuilder: (context, index) => MyDivider(),
                  itemBuilder: (context, index) =>
                      CustomGameItem(gameModel: state.games[index]),
                  itemCount: state.games.length,
                );
              } else if (state is GetGameFailureState) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(state.errorMessage)),
                );
              } else {
                return SliverToBoxAdapter(
                  child: Skeletonizer(
                    child: ListView.builder(
                       shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), 
                      itemBuilder: (context, index) => CustomGameItem(gameModel: getDummyGames()),
                      itemCount: 5,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
