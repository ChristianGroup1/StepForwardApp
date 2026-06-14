import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.hintText,
  });
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.grey.shade300;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        suffixIconColor: const Color(0xff949D9E),
        prefixIcon: const Icon(
          Icons.search,
          size: 40,
          color: AppColors.primaryColor,
        ),
        hintText: hintText ?? (context.isEn ? 'Search here' : 'ابحث هنا'),
        hintStyle: TextStyles.regular16.copyWith(
          color: const Color(0xff949D9E),
        ),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        border: buildBorder(color: borderColor),
        enabledBorder: buildBorder(color: borderColor),
        focusedBorder: buildBorder(color: AppColors.lightPrimaryColor),
      ),
    );
  }

  OutlineInputBorder buildBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color ?? Colors.grey.shade300, width: 1.5),
    );
  }
}
