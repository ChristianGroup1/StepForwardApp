import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:stepforward/core/utils/app_colors.dart';

void customQuickAlertView(
  BuildContext context, {
  required String text,
  required String title,
  required String confirmBtnText,
  required QuickAlertType type,
  required void Function()? onConfirmBtnTap,
  String? cancelBtnText,
}) {
  QuickAlert.show(
    context: context,
    type: type,
    title: title,
    text: text,
    confirmBtnText: confirmBtnText,
    onConfirmBtnTap: onConfirmBtnTap,
    cancelBtnText:  "إلغاء",
    confirmBtnColor: AppColors.secondaryColor,
  );
}
