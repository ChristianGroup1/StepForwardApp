import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/features/auth/data/login_cubit/login_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/dont_have_an_account.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/login_method_item.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/or_divider.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key, required this.cubit});

  final LoginCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffEEF2F7), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kHorizontalPadding,
          vertical: 32,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: cubit.formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      Assets.assetsImagesStepForwardLogo,
                      height: 100.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                verticalSpace(24),
                Text(
                  'اهلًا بعودتك إلى Step Forward',
                  style: TextStyles.bold23.copyWith(
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpace(8),
                Text(
                  'سجّل دخولك للمتابعة',
                  style: TextStyles.regular14.copyWith(
                    color: const Color(0xff949D9E),
                  ),
                ),
                verticalSpace(28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextFormField(
                        textInputType: TextInputType.emailAddress,
                        labelText: 'البريد الإلكتروني',
                        onChanged: (value) {
                          cubit.emailController.text = value;
                        },
                      ),
                      verticalSpace(20),
                      CustomTextFormField(
                        suffixIcon: GestureDetector(
                          onTap: () => cubit.changePasswordVisibility(),
                          child: cubit.suffixIcon,
                        ),
                        isObscured: cubit.isObscured,
                        labelText: 'كلمة المرور',
                        onChanged: (value) {
                          cubit.passwordController.text = value;
                        },
                      ),
                      verticalSpace(12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: GestureDetector(
                          onTap: () =>
                              context.pushNamed(Routes.forgetPasswordView),
                          child: Text(
                            'نسيت كلمة المرور ؟ ',
                            style: TextStyles.bold16.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(20),
                      CustomButton(
                        text: 'تسجيل دخول',
                        textColor: Colors.white,
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.login();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                verticalSpace(24),
                const DontHaveAnAccount(),
                verticalSpace(24),
                const OrDivider(),
                verticalSpace(24),
                LoginMethodItem(
                  image: Assets.assetsImagesGoogleIcon,
                  text: 'تسجيل الدخول بواسطة جوجل',
                  onTap: () {
                    AnalyticsService.logLogin(method: 'google');
                    cubit.signInWIthGoogle();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
