
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class LoginMethodItem extends StatelessWidget {
  const LoginMethodItem({
    super.key, required this.image, required this.text, this.onTap,
  });
final String image,text;
final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
        width: double.infinity,
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(
              0xffDDDFDF,
            ),
          ),
          borderRadius: BorderRadius.circular(
            16,
          ),
        )),
        child: Row(
          children: [
            SvgPicture.asset(image),
            const Spacer(),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyles.bold13,
            ),
            const Spacer() 
          ],
        ),
      ),
    );
  }
}