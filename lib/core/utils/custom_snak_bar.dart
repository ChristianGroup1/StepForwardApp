import 'package:flutter/material.dart';

void showSnackBar(BuildContext context,
    {required String text, Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      content: Text(
        text,
      ),
      backgroundColor: color,
    ),
  );
}