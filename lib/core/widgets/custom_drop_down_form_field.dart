import 'package:flutter/material.dart';
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
    final String? selectedValue =
        (items != null && items!.any((item) => item.value == value))
        ? value
        : null;
    return DropdownButtonFormField<String>(
      hint: Text(
        'المحافظة',
        style: TextStyles.bold13.copyWith(color: const Color(0xff949D9E)),
      ),
      value: selectedValue, // Default selected value
      decoration: InputDecoration(
        labelStyle: TextStyles.bold16.copyWith(color: const Color(0xff949D9E)),

        hintStyle: TextStyles.bold13.copyWith(color: const Color(0xff949D9E)),
        filled: true,
        fillColor: const Color(0xffF9FAFA),
        border: buildBorder(),
        enabledBorder: buildBorder(),
        focusedBorder: buildBorder(),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار المحافظة';
        }
        return null;
      },
    );
  }

  OutlineInputBorder buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: const BorderSide(color: Color(0xffE6E9E9)),
    );
  }
}
