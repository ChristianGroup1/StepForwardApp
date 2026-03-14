
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class LoginMethodItem extends StatelessWidget {
  const LoginMethodItem({
    super.key,
    required this.image,
    required this.text,
    this.onTap,
  });

  final String image, text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: const Color(0xffEEEEEE),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(image),
            const Spacer(),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyles.bold13,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}