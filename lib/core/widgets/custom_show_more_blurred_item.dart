import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';

class CustomShowMoreBlurredItem extends StatelessWidget {
  const CustomShowMoreBlurredItem({
    super.key,
    required this.blurImageUrl,
  });

  final String blurImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 16,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height:
                  MediaQuery.sizeOf(context).height *
                  0.15,
              width:
                  MediaQuery.sizeOf(context).width *
                  0.22,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  CustomCachedNetworkImageWidget(
                    imageUrl: blurImageUrl,
                    borderRadius: 16,
                    fit: BoxFit.cover,
                  ),
                  // Actual blur effect
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 6.0,
                          sigmaY: 6.0,
                        ),
                        child: Container(
                          color: Colors.black
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  // Centered Text
                  const Center(
                    child: Text(
                      'اظهر المزيد',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
