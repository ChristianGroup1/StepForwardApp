import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/get_dummy_games.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
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
    final isEn = context.isEn;
    final cubit = context.watch<GamesCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding,
        vertical: kVerticalPadding,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CustomPageAppBar(title: isEn ? 'Games' : 'الألعاب'),
          ),
          SliverToBoxAdapter(child: verticalSpace(24)),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                    horizontalSpace(6),
                    Text(
                      isEn ? 'Search by game target' : 'البحث بهدف اللعبة',
                      style: TextStyles.bold16.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                verticalSpace(8),
                SearchTextField(
                  controller: context.read<GamesCubit>().searchController,
                  onChanged: (value) =>
                      context.read<GamesCubit>().searchGames(),
                  hintText: isEn
                      ? 'Example: prayer, faith, teamwork'
                      : 'مثال: صلاة، إيمان، تعاون',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: verticalSpace(20)),
          SliverToBoxAdapter(
            child: _FilterHeader(
              icon: Icons.group_outlined,
              title: isEn ? 'Choose age group' : 'اختار السن',
            ),
          ),
          SliverToBoxAdapter(child: verticalSpace(8)),
          SliverToBoxAdapter(
            child: TagsList(
              tags: isEn
                  ? ['Children', 'Middle School', 'High School', 'University']
                  : ['اطفال', 'اعدادي', 'ثانوي', 'جامعة'],
              onTagToggle: cubit.toggleTag,
              selectedTags: cubit.selectedTags,
            ),
          ),
          if (cubit.availableTargets.isNotEmpty) ...[
            SliverToBoxAdapter(child: verticalSpace(20)),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _FilterHeader(
                      icon: Icons.track_changes_outlined,
                      title: isEn ? 'Choose target' : 'اختار الهدف',
                    ),
                  ),
                  if (cubit.selectedTags.isNotEmpty ||
                      cubit.selectedTarget != null ||
                      cubit.searchController.text.isNotEmpty)
                    TextButton(
                      onPressed: cubit.clearFilters,
                      child: Text(isEn ? 'Clear' : 'مسح'),
                    ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: verticalSpace(8)),
            SliverToBoxAdapter(
              child: TagsList(
                tags: cubit.availableTargets,
                onTagToggle: cubit.selectTarget,
                selectedTags: [
                  if (cubit.selectedTarget != null) cubit.selectedTarget!,
                ],
              ),
            ),
          ],
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
                  text: isEn
                      ? 'Game added to favorites'
                      : 'تم اضافة اللعبة للمفضلة',
                  color: Colors.green,
                );
              }
              if (state is RemoveGameFromFavoritesSuccessState) {
                showSnackBar(
                  context,
                  text: isEn
                      ? 'Game removed from favorites'
                      : 'تم حذف اللعبة من المفضلة',
                  color: Colors.red,
                );
              }
            },
            builder: (context, state) {
              if (state is GetGamesSuccessState) {
                if (state.games.isEmpty) {
                  return SliverToBoxAdapter(
                    child: CustomEmptyWidget(
                      title: isEn
                          ? 'No games match these filters'
                          : 'لا توجد ألعاب تناسب هذه الفلاتر',
                      subtitle: isEn
                          ? 'Try another target or age group'
                          : 'جرّب هدف أو سن مختلف',
                    ),
                  );
                }
                return SliverList.separated(
                  separatorBuilder: (context, index) => const MyDivider(),
                  itemBuilder: (context, index) {
                    final game = state.games[index];
                    return CustomGameItem(
                      gameModel: game,
                      isNew: cubit.isNewestGame(game),
                    );
                  },
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
                      itemBuilder: (context, index) =>
                          CustomGameItem(gameModel: getDummyGames()),
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

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        horizontalSpace(6),
        Text(
          title,
          style: TextStyles.bold16.copyWith(color: AppColors.primaryColor),
        ),
      ],
    );
  }
}
