import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class ActiveNavigationItem extends StatelessWidget {
  const ActiveNavigationItem({
    super.key,
    required this.image,
    required this.title,
  });

  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            image,
            color: AppColors.secondaryColor,
            width: 22.w,
            height: 22.w,
          ),
          SizedBox(width: 6.w),
          Text(
            title,
            style: TextStyles.bold13.copyWith(
              color: AppColors.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
