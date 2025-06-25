import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';


class ActiveStepItem extends StatelessWidget {
  const ActiveStepItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 13.r, // Adjust dynamically for screen size
          backgroundColor: AppColors.primaryColor,
          child: const Icon(
            Icons.check,
            color: Colors.white,
          
          ),
        ),
        horizontalSpace(3.w),
        Flexible(
          child: Text(
            text,
            style: TextStyles.bold13.copyWith(
              color: AppColors.primaryColor,
             
            ),
            overflow: TextOverflow.ellipsis, // Handles long text
          ),
        ),
      ],
    );
  }
}
