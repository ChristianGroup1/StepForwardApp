// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/features/home/data/more_cubit/more_cubit.dart';

void showPasswordQuickAlert(BuildContext context, MoreCubit cubit) {
  final isEn = context.isEn;
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  QuickAlert.show(
    context: context,
    type: QuickAlertType.info,
    title: isEn ? 'Confirm Password' : 'تأكيد كلمة المرور',
    confirmBtnText: isEn ? 'Confirm' : 'تأكيد',
    cancelBtnText: isEn ? 'Cancel' : 'إلغاء',
    showCancelBtn: true,
    barrierDismissible: false,
    widget: Form(
      key: formKey,
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: isEn ? 'Password' : 'كلمة المرور',
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return isEn ? 'Please enter your password' : 'يرجى إدخال كلمة المرور';
          }
          return null;
        },
      ),
    ),
    onConfirmBtnTap: () async {
      if (formKey.currentState!.validate()) {
        context.pop();

        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          title: isEn ? 'Confirming Password' : 'تأكيد كلمة المرور',
          barrierDismissible: false,
        );

        bool isAuthenticated =
            await cubit.reauthenticateUser(passwordController.text);

        context.pop();

        if (isAuthenticated) {
          confirmDeleteAccount(context, cubit, passwordController.text);
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: isEn ? 'Incorrect Password' : 'كلمة المرور غير صحيحة',
            text: isEn
                ? 'Please check your password and try again'
                : 'يرجى التأكد من كلمة المرور الخاصة بك',
            confirmBtnText: isEn ? 'OK' : 'حسنا',
            cancelBtnText: isEn ? 'Cancel' : 'إلغاء',
            showCancelBtn: true,
            onCancelBtnTap: () {
              context.pushNamed(Routes.forgetPasswordView);
            },
          );
        }
      }
    },
  );
}

void confirmDeleteAccount(
    BuildContext context, MoreCubit cubit, String? password) {
  final isEn = context.isEn;
  customQuickAlertView(
    context,
    text: isEn
        ? 'Are you sure you want to delete your account?'
        : 'هل أنت متأكد من حذف حسابك؟',
    title: isEn ? 'Delete Your Account' : 'حذف حسابك',
    type: QuickAlertType.warning,
    confirmBtnText: isEn ? 'Delete' : 'حذف',
    onConfirmBtnTap: () async {
      await cubit.deleteAccount(uId: getUserData().id, password: password);
      context.pushNamedAndRemoveUntil(
        Routes.onBoardingView,
        predicate: (Route<dynamic> route) => false,
      );
    },
  );
}
