import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_colors.dart';

BoxDecoration customBoxDecoration({double? opacity, Color? mainColor,double? radius}) {
  return BoxDecoration(
    color: mainColor ?? Colors.grey[200],
    borderRadius: BorderRadius.circular(radius ?? 16.0),
    border: Border.all(color: AppColors.lightPrimaryColor, width: 1.5),
  );
}

  BoxDecoration customCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Color(0xff949D9E),
          blurRadius: 7,
          spreadRadius: 1,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

