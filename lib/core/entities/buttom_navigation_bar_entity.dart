import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_images.dart';


class ButtonNavigationBarEntity {
  final String activeImage, inActiveImage;
  final String Function(BuildContext) name; // Change to function returning a localized string

  ButtonNavigationBarEntity({
    required this.activeImage,
    required this.inActiveImage,
    required this.name,
  });
}

List<ButtonNavigationBarEntity> buttonNavigationBarEntityList = [
  ButtonNavigationBarEntity(
    name: (context) =>'الرئيسية', // Use localized text
    activeImage: Assets.assetsImagesInActiveHome,
    inActiveImage: Assets.assetsImagesInActiveHome,
  ),
  ButtonNavigationBarEntity(
    name: (context) =>'الالعاب', // Use localized text
    activeImage: Assets.assetsImagesGamesIcon,
    inActiveImage: Assets.assetsImagesGamesIcon,
  ),
  ButtonNavigationBarEntity(
    name: (context) =>'الخدام', // Use localized text
    activeImage: Assets.assetsImagesPeopleIcon,
    inActiveImage: Assets.assetsImagesPeopleIcon,
  ),
   ButtonNavigationBarEntity(
    name: (context) =>'المزيد', // Use localized text
    activeImage: Assets.assetsImagesMoreActive,
    inActiveImage: Assets.assetsImagesMoreInactive,
  ),
];