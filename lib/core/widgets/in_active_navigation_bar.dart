import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';

class InActiveNavigationItem extends StatelessWidget {
  const InActiveNavigationItem({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      color: Colors.white,
      image,
      height: isDeviceInPortrait(context)? 25.h :65.h,
      width: 25.w,
    );
  }
}