import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';


class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, required this.text, this.backgroundColor, this.textColor, this.height, this.width, this.padding});
  final void Function()? onPressed;
  final String text;
  final Color?backgroundColor;
  final Color?textColor;
  final double? height;
    final double? width;
    final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:width?? double.infinity,
      height: height?? 54.h,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor:backgroundColor?? AppColors.primaryColor,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: padding?? EdgeInsets.zero,
          child: Text(text,style: TextStyles.bold16.copyWith(color:textColor?? Colors.white),),
        ),
      ),
    );
  }
}
