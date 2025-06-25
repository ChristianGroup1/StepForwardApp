import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final TextInputType? textInputType;
  final int maxLines;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? contentPadding;
  final bool? isObscured;
  final void Function(String)? onChanged;
  final bool needsValidation;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String? labelText;
  final String? initialValue;
  final bool readOnly;
  final TextAlign? textAlign;
  final double? borderRadius;
  final InputBorder? border;
  final bool? isDense;
  final Color? fillColor;
  final TextStyle? style;
  final void Function(String?)? onSaved;
  final TextStyle? hintStyle;
  const CustomTextFormField(
      {super.key,
      this.hintText,
      this.labelText,
      this.border,
      this.style,
      this.hintStyle,
      this.initialValue,
      this.isDense,
      this.borderRadius,
      this.fillColor,
      this.textInputType,
      this.validator,
      this.readOnly = false,
      this.suffixIcon,
      this.onChanged,
      this.controller,
      this.isObscured,
      this.textAlign,
      this.maxLines = 1,
      this.contentPadding,
      this.needsValidation = true,
      this.onFieldSubmitted,
      this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      initialValue: initialValue,
      onSaved: onSaved,
      readOnly: readOnly,
      textAlign: textAlign ?? TextAlign.start,
      obscureText: isObscured ?? false,
      onChanged: onChanged,
      style: style,
      validator: needsValidation
          ? validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'هذا الحقل مطلوب';
                }
                return null;
              }
          : null,
      keyboardType: textInputType ?? TextInputType.emailAddress,
      decoration: InputDecoration(
        hintMaxLines: maxLines,
        isDense: isDense,
        labelText: labelText,
        contentPadding: contentPadding,
        suffixIcon: suffixIcon,
        suffixIconColor: const Color(0xff949D9E),
        hintText: hintText,
        hintStyle: hintStyle ??
            TextStyles.bold13.copyWith(
              color: const Color(0xff949D9E),
            ),
        filled: true,
        fillColor: fillColor ?? const Color(0xffF9FAFA),
        border: border ?? buildBorder(),
        enabledBorder: border ?? buildBorder(),
        focusedBorder: border ?? buildBorder(),
      ),
    );
  }

  OutlineInputBorder buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        borderRadius ?? 4.0,
      ),
      borderSide: const BorderSide(
        color: Color(0xffE6E9E9),
      ),
    );
  }
}
