import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';



class DontHaveAnAccount extends StatelessWidget {
  const DontHaveAnAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(
        text: 'لا تمتلك حساب؟ ',
        style: TextStyles.semiBold16.copyWith(
          color: const Color(
            0xff949D9E,
          ),
        ),
      ),
      TextSpan(recognizer: TapGestureRecognizer()..onTap = () {
        CacheHelper.removeData(key: kSaveUserDataKey);
        context.pushNamed(Routes.signUpView);
      },
        text: 'قم بإنشاء حساب',
        style: TextStyles.bold16.copyWith(
          color: AppColors.primaryColor,
        ),
      ),
    ]));
  }
}