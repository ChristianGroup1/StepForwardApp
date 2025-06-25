import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
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
  const LoginViewBody({
    super.key,
    required this.cubit,
  });

  final LoginCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(12),
                child: Image.asset(
                  Assets.assetsImagesStepForwardLogo,
                  height: 150.h,
                  fit: BoxFit.cover,
                ),
              ),
              verticalSpace(30),
              Text(
                'اهلًا بعودتك إلى Step Forward',
                style: TextStyles.bold23,
              ),
    
              verticalSpace(30),
              CustomTextFormField(
                textInputType: TextInputType.emailAddress,
                labelText: 'البريد الإلكتروني',
                onChanged: (value) {
                  cubit.emailController.text = value;
                },
              ),
              verticalSpace(24),
              CustomTextFormField(
                suffixIcon: GestureDetector(
                  onTap: () => cubit.changePasswordVisibility(),
                  child: cubit.suffixIcon),
                isObscured: cubit.isObscured,
               
                labelText: 'كلمة المرور',
                onChanged: (value) {
                  cubit.passwordController.text = value;
                },
              ),
              verticalSpace(16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GestureDetector(
                   onTap: () => context.pushNamed(Routes.forgetPasswordView),
                  child: Text(
                    'نسيت كلمة المرور ؟ ',
                    style: TextStyles.bold16.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              verticalSpace(24),
              CustomButton(
                text: 'تسجيل دخول',
                textColor: Colors.white,
                onPressed: () {
                  if (cubit.formKey.currentState!.validate()) {
                    cubit.login();
                  }
                },
              ),
              verticalSpace(24),
              DontHaveAnAccount(),
              verticalSpace(24),
              OrDivider(),
              verticalSpace(24),
              LoginMethodItem(
                image: Assets.assetsImagesGoogleIcon,
                text: 'تسجيل الدخول بواسطة جوجل',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
