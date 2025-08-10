import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_images.dart';

class CustomCachedNetworkImageWidget extends StatelessWidget {
  const CustomCachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    required this.borderRadius,
    this.width,
    this.fit,
    this.height,
  });

  final String imageUrl;
  final double borderRadius;
  final double? width;
  final double? height;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        fit: fit,
        width: width,
        height: height,
        imageUrl: imageUrl,
        placeholder: (context, url) => LoadingAnimationWidget.threeRotatingDots(
          color: AppColors.lightSecondaryColor,
          size: 23,
        ),
        errorWidget: (context, url, error) =>
            Image.asset(Assets.assetsImagesStepForwardLogo),
      ),
    );
  }
}
