import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class CustomDropDownButtonFormField extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;

  const CustomDropDownButtonFormField({
    super.key,
    this.value,
    this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.14)
        : const Color(0xffE6E9E9);
    final String? selectedValue =
        (items != null && items!.any((item) => item.value == value))
        ? value
        : null;
    return DropdownButtonFormField<String>(
      hint: Text(
        isEn ? 'Governorate' : 'المحافظة',
        style: TextStyles.bold13.copyWith(color: const Color(0xff949D9E)),
      ),
      value: selectedValue,
      decoration: InputDecoration(
        labelStyle: TextStyles.bold16.copyWith(color: const Color(0xff949D9E)),
        hintStyle: TextStyles.bold13.copyWith(color: const Color(0xff949D9E)),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        border: _buildBorder(color: borderColor),
        enabledBorder: _buildBorder(color: borderColor),
        focusedBorder: _buildBorder(color: theme.colorScheme.primary),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isEn ? 'Please select a governorate' : 'يرجى اختيار المحافظة';
        }
        return null;
      },
    );
  }

  OutlineInputBorder _buildBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(color: color ?? const Color(0xffE6E9E9)),
    );
  }
}
