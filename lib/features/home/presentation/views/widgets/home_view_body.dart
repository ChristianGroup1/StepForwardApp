import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_home_app_bar.dart';

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
          SliverToBoxAdapter(
            child: Row(
              children: [
                Text('خدام محافظة المنيا ', style: TextStyles.bold16),
                Spacer(),
                Text('المزيد', style: TextStyles.semiBold13.copyWith(color: Color(0xffA5A5A5))),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(16),
                        child: Image.asset(Assets.assetsImagesStepForwardLogo)),
                    ),
                itemCount: 10,
              ),
            ),
          ),
          SliverToBoxAdapter(child: verticalSpace(24)),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Text('العاب لاجتماع اعدادي', style: TextStyles.bold16),
                Spacer(),
                Text('المزيد', style: TextStyles.semiBold13.copyWith(color: Color(0xffA5A5A5))),
              ],
            ),
          ),
            SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(16),
                        child: Image.asset(Assets.assetsImagesStepForwardLogo)),
                    ),
                itemCount: 10,
              ),
            ),
          ),
            SliverToBoxAdapter(child: verticalSpace(24)),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Text('فرق رياضية في المنيا', style: TextStyles.bold16),
                Spacer(),
                Text('المزيد', style: TextStyles.semiBold13.copyWith(color: Color(0xffA5A5A5))),
              ],
            ),
          ),
            SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(16),
                        child: Image.asset(Assets.assetsImagesStepForwardLogo)),
                    ),
                itemCount: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
