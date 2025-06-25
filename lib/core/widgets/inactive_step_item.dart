import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';

class InActiveStepItem extends StatelessWidget {
  const InActiveStepItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 12.r, // Adjusts dynamically for screen size
          backgroundColor: Colors.grey,
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 16.sp, // Adjusts icon size
          ),
        ),
        horizontalSpace(3.w),
        Flexible(
          child: Text(
            text,
            style: TextStyles.bold13.copyWith(
              color: Colors.grey,
             
            ),
            overflow: TextOverflow.ellipsis, // Handles long text
          ),
        ),
      ],
    );
  }
}
