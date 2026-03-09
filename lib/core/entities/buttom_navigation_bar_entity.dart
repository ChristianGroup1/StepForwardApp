import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/generated/l10n.dart';

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
    name: (context) => S.of(context).home,
    activeImage: Assets.assetsImagesInActiveHome,
    inActiveImage: Assets.assetsImagesInActiveHome,
  ),
  ButtonNavigationBarEntity(
    name: (context) => S.of(context).games,
    activeImage: Assets.assetsImagesGamesIcon,
    inActiveImage: Assets.assetsImagesGamesIcon,
  ),
  ButtonNavigationBarEntity(
    name: (context) => S.of(context).servants,
    activeImage: Assets.assetsImagesPeopleIcon,
    inActiveImage: Assets.assetsImagesPeopleIcon,
  ),
  ButtonNavigationBarEntity(
    name: (context) => S.of(context).more,
    activeImage: Assets.assetsImagesMoreActive,
    inActiveImage: Assets.assetsImagesMoreInactive,
  ),
];
