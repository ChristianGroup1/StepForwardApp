import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_home_app_bar.dart';
import 'package:stepforward/features/home/presentation/views/widgets/books_section_home_view.dart';
import 'package:stepforward/features/home/presentation/views/widgets/brothers_section_home_view.dart';
import 'package:stepforward/features/home/presentation/views/widgets/games_section_home_view.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

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
          SliverToBoxAdapter(child: CustomHomeAppBar()),
          SliverToBoxAdapter(child: verticalSpace(24)),
          BrothersSectionHomeView(),

          SliverToBoxAdapter(child: verticalSpace(24)),
          GamesSectionHomeView(),
          SliverToBoxAdapter(child: verticalSpace(24)),
          BooksSectionHomeView(),
        ],
      ),
    );
  }
}
