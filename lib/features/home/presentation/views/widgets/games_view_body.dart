import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/data/home_cubit/home_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_game_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/tags_list.dart';

class GamesViewBody extends StatelessWidget {
  const GamesViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding,
        vertical: kVerticalPadding,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SearchTextField()),
          SliverToBoxAdapter(child: verticalSpace(20)),
          SliverToBoxAdapter(
            child: TagsList(tags: ['اطفال', 'اعدادي', 'ثانوي', 'جامعة']),
          ),
          SliverToBoxAdapter(child: verticalSpace(24)),
          BlocConsumer<HomeCubit, HomeState>(
            buildWhen: (previous, current) =>
                current is GetGamesSuccessState ||
                current is GetGameFailureState ||
                current is GetGamesLoadingState,
            listener: (context, state) {
              if (state is GetGameFailureState) {
                log(state.errorMessage);
              }
              if (state is AddGameToFavoritesSuccessState) {
                showSnackBar(context, text:'تم اضافة اللعبة للمفضلة',color: Colors.green);
              }
              if (state is RemoveGameFromFavoritesSuccessState) {
                showSnackBar(context, text:'تم حذف اللعبة من المفضلة',color: Colors.red);
              }
              
            },
            builder: (context, state) {
              if (state is GetGamesSuccessState) {
                return getUserData().isApproved? SliverList.separated(
                  separatorBuilder: (context, index) => MyDivider(),
                  itemBuilder: (context, index) =>
                      CustomGameItem(gameModel: state.games[index],
                      userFavorites:context.watch<HomeCubit>().userFavorites,
                      ),
                  itemCount: state.games.length,
                ) : SliverToBoxAdapter(child: Center(child: Text('لم يتم الموافقة على الحساب',style: TextStyle(color: Colors.red),),));
              } else if (state is GetGameFailureState) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(state.errorMessage)),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: CustomAnimatedLoadingWidget(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
