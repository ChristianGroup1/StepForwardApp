import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_images.dart';

class ButtonNavigationBarEntity {
  final String activeImage, inActiveImage;
  final String Function(BuildContext) name;

  ButtonNavigationBarEntity({
    required this.activeImage,
    required this.inActiveImage,
    required this.name,
  });
}

List<ButtonNavigationBarEntity> buttonNavigationBarEntityList = [
  ButtonNavigationBarEntity(
    name: (context) => context.isEn ? 'Home' : 'الرئيسية',
    activeImage: Assets.assetsImagesInActiveHome,
    inActiveImage: Assets.assetsImagesInActiveHome,
  ),
  ButtonNavigationBarEntity(
    name: (context) => context.isEn ? 'Games' : 'الالعاب',
    activeImage: Assets.assetsImagesGamesIcon,
    inActiveImage: Assets.assetsImagesGamesIcon,
  ),
  ButtonNavigationBarEntity(
    name: (context) => context.isEn ? 'Servants' : 'الخدام',
    activeImage: Assets.assetsImagesPeopleIcon,
    inActiveImage: Assets.assetsImagesPeopleIcon,
  ),
  ButtonNavigationBarEntity(
    name: (context) => context.isEn ? 'More' : 'المزيد',
    activeImage: Assets.assetsImagesMoreActive,
    inActiveImage: Assets.assetsImagesMoreInactive,
  ),
];
