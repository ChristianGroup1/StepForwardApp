import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/sign_up_text_fields.dart';

class SignUpViewBody extends StatelessWidget {
  const SignUpViewBody({super.key, required this.cubit});

  final SignUpCubit cubit;

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding,
        vertical: kVerticalPadding,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      context.pop();
                    },
                  ),
                  Text(
                    isEn ? 'Create New Account' : 'إنشاء حساب جديد',
                    style: TextStyles.bold28.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              verticalSpace(16),
              Text(
                isEn
                    ? 'Create an account to be part of our team'
                    : 'قم بإنشاء حساب لتتمتع لتكون جزء من فريقنا  ',
                style: TextStyles.bold13.copyWith(
                  color: const Color(0xff949D9E),
                ),
              ),
              verticalSpace(32),
              SignUpTextFields(cubit: cubit),
              CustomButton(
                text: isEn ? 'Create Account' : 'انشاء حساب',
                onPressed: () {
                  if (cubit.formKey.currentState!.validate()) {
                    cubit.signUp();
                  }
                },
              ),
              verticalSpace(48),
            ],
          ),
        ),
      ),
    );
  }
}
