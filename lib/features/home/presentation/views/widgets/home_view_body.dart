import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_home_app_bar.dart';
import 'package:stepforward/features/home/presentation/views/widgets/books_section_home_view.dart';
import 'package:stepforward/features/home/presentation/views/widgets/brothers_section_home_view.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_slider_widget.dart';
import 'package:stepforward/features/home/presentation/views/widgets/games_section_home_view.dart';

class HomeViewBody extends StatelessWidget {
     final VoidCallback onNavigateToGamesView;
   final VoidCallback onNavigateToBrothersView;

  const HomeViewBody({super.key, required this.onNavigateToGamesView, required this.onNavigateToBrothersView});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding,
        vertical: kVerticalPadding,
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: verticalSpace(16)),
          SliverToBoxAdapter(child: CustomHomeAppBar()),
          SliverToBoxAdapter(child: verticalSpace(16)),
          SliverToBoxAdapter(
            child: CustomSliderWidget(
              onNavigateToBrothersView: onNavigateToBrothersView,
              onNavigateToGamesView: onNavigateToGamesView,
            ),
          ),

          SliverToBoxAdapter(child: verticalSpace(12)),
          GamesSectionHomeView( onNavigateToGamesView: onNavigateToGamesView,),
          SliverToBoxAdapter(child: verticalSpace(8)),
          BrothersSectionHomeView(onNavigateToBrothersView: onNavigateToBrothersView,),
          SliverToBoxAdapter(child: verticalSpace(8)),
          BooksSectionHomeView(),
        ],
      ),
    );
  }
}

