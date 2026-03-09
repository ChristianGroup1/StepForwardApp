import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      this.onPressed,
      required this.text,
      this.backgroundColor,
      this.borderRadius,
      this.textColor,
      this.height,
      this.width,
      this.padding});
  final void Function()? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 16.0;
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 54.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: backgroundColor == null
              ? const LinearGradient(
                  colors: [AppColors.lightPrimaryColor, AppColors.primaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            backgroundColor: Colors.transparent,
          ),
          onPressed: onPressed,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Text(
              text,
              style: TextStyles.bold16.copyWith(color: textColor ?? Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}