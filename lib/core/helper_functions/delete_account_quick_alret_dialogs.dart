  import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/features/home/data/more_cubit/more_cubit.dart';

void showPasswordQuickAlert(
      BuildContext context, MoreCubit cubit) {
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    

    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: 'تأكيد كلمة المرور',
      confirmBtnText: 'تأكيد',
      cancelBtnText: 'إلغاء',
      showCancelBtn: true,
      barrierDismissible: false,
      widget: Form(
        key: formKey,
        child: TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'كلمة المرور',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
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
            title: 'تأكيد كلمة المرور',
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
                title: 'كلمة المرور غير صحيحة',
                text: 'يرجى التأكد من كلمة المرور الخاصة بك',
                confirmBtnText: 'حسنا',
                cancelBtnText: 'إلغاء',
                showCancelBtn: true,
                onCancelBtnTap: () {
                  context.pushNamed(Routes.forgetPasswordView);
                });
          }
        }
      },
    );
  }

  void confirmDeleteAccount(
      BuildContext context, MoreCubit cubit, String? password) {
  

    customQuickAlertView(
      context,
      text: 'هل أنت متأكد من حذف حسابك؟',
      title: 'حذف حسابك',
      type: QuickAlertType.warning,
      confirmBtnText: 'حذف',
      onConfirmBtnTap: () async {
        await cubit.deleteAccount(uId: getUserData().id, password: password);
        context.pushNamedAndRemoveUntil(
          Routes.onBoardingView,
          predicate: (Route<dynamic> route) => false,
        );
      },
    );
      }