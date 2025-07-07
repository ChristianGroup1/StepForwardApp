import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/sign_up_text_fields.dart';

class CompleteUserProfileViewBody extends StatelessWidget {
  final UserModel? user;
  const CompleteUserProfileViewBody({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccessState) {
          context.pushNamedAndRemoveUntil(
            Routes.mainView,
            predicate: (Route<dynamic> route) => false,
          );
        }
        if (state is SignUpFailureState) {
          customQuickAlertView(
            context,
            text: state.errorMessage,
            title: 'حدث خطأ',
            confirmBtnText: 'حسنا',
            type: QuickAlertType.error,
            onConfirmBtnTap: () {
              context.pop();
            },
          );
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is SignUpLoadingState,
          progressIndicator: CustomAnimatedLoadingWidget(),
          blur: 1.5,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: kHorizontalPadding,
                  vertical: kVerticalPadding,
                ),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    children: [
                      Text('بيانات الحساب', style: TextStyles.bold23),
                      verticalSpace(16),
                      SignUpTextFields(cubit: cubit, user: user),
                      CustomButton(
                        text: 'إنشاء الحساب',
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.completeGoogleSignUp(userId: user!.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
