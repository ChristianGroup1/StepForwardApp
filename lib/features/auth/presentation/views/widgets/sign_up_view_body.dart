import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/sign_up_text_fields.dart';

class SignUpViewBody extends StatelessWidget {
  const SignUpViewBody({
    super.key,
    required this.cubit,
  });

  final SignUpCubit cubit;

  @override
  Widget build(BuildContext context) {
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
              Text(
                'إنشاء حساب جديد',
                style: TextStyles.bold28.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              verticalSpace(16),
              Text(
                'قم بإنشاء حساب لتتمتع بكل مميزات التطبيق',
                style: TextStyles.bold13.copyWith(
                  color: const Color(0xff949D9E),
                ),
              ),
              verticalSpace(32),
              SignUpTextFields(cubit: cubit),
              CustomButton(
                text: 'انشاء حساب',
                onPressed: () {
                  if (cubit.formKey.currentState!.validate()) {
                    if (cubit.frontId != null && cubit.backId != null) {
                      cubit.signUp();
                    } else {
                      customQuickAlertView(
                        context,
                        text: 'يرجى اضافة صور البطاقة',
                        title: 'حدث خطأ',
                        confirmBtnText: 'حسنا',
                        type: QuickAlertType.error,
                        onConfirmBtnTap: () {
                          context.pop();
                        },
                      );
                    }
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
