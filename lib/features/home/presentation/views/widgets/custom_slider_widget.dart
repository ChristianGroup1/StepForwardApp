import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/features/home/domain/models/slider_model.dart';

class CustomSliderWidget extends StatelessWidget {
   final VoidCallback onNavigateToGamesView;
   final VoidCallback onNavigateToBrothersView;
  const CustomSliderWidget({
    super.key, required this.onNavigateToGamesView, required this.onNavigateToBrothersView,
  });

  @override
  Widget build(BuildContext context) {
    final List<SliderModel> sliderList = [
  SliderModel(image: Assets.assetsImagesGamesSlider, route: onNavigateToGamesView),
  SliderModel(image: Assets.assetsImagesBrothersSlider, route: onNavigateToBrothersView),
];
    return CarouselSlider.builder(
      itemCount: 2,
      itemBuilder: (context, index, realIndex) =>
          GestureDetector(
            onTap: sliderList[index].route,
            child: Image.asset(sliderList[index].image, fit: BoxFit.fill,)),
      options: CarouselOptions(
        height:isDeviceInPortrait(context)? MediaQuery.sizeOf(context).height * 0.2:  MediaQuery.sizeOf(context).height * 0.3,
        
        viewportFraction: 1,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
      ),
    );
  }
}
