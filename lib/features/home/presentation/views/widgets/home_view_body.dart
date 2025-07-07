import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_home_app_bar.dart';
import 'package:stepforward/features/home/presentation/views/widgets/books_section_home_view.dart';
import 'package:stepforward/features/home/presentation/views/widgets/brothers_section_home_view.dart';
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
            child: CarouselSlider.builder(
              itemCount: 2,
              itemBuilder: (context, index, realIndex) =>
                  Image.asset(Assets.assetsImagesGamesSlider),
              options: CarouselOptions(
                height: MediaQuery.sizeOf(context).height * 0.25,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
              ),
            ),
          ),

          SliverToBoxAdapter(child: verticalSpace(24)),
          GamesSectionHomeView( onNavigateToGamesView: onNavigateToGamesView,),
          SliverToBoxAdapter(child: verticalSpace(24)),
          BrothersSectionHomeView(onNavigateToBrothersView: onNavigateToBrothersView,),
          SliverToBoxAdapter(child: verticalSpace(24)),
          BooksSectionHomeView(),
        ],
      ),
    );
  }
}
