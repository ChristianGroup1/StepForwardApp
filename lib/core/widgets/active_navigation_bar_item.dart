import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            image,
            color: Colors.white,
            width: 24.w,
            height: 24.w,
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyles.bold13.copyWith(
              color: Colors.white,
             
            ),
          ),
        ],
      ),
    );
  }
}
