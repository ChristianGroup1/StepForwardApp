import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key, this.onChanged, this.controller});
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        suffixIconColor: const Color(0xff949D9E),
        prefixIcon: const Icon(
          Icons.search,
          size: 40,
          color: AppColors.primaryColor,
        ),
        hintText: context.isEn ? 'Search here' : 'ابحث هنا',
        hintStyle: TextStyles.regular16.copyWith(
          color: const Color(0xff949D9E),
        ),
        filled: true,
        fillColor: const Color(0xffF9FAFA),
        border: buildBorder(),
        enabledBorder: buildBorder(),
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
