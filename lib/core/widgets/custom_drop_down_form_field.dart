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
        fillColor: const Color(0xffF9FAFA),
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildBorder(),
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

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: const BorderSide(color: Color(0xffE6E9E9)),
    );
  }
}
