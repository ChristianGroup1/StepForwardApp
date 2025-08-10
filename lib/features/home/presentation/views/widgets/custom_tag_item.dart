import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_box_decoration.dart';

class CustomTagItem extends StatelessWidget {
  final String tagName;
  final bool isSelected;
  final VoidCallback onTap;
  const CustomTagItem({
    super.key,
    required this.tagName, required this.isSelected, required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        alignment: Alignment.center,
        decoration: customBoxDecoration(
          mainColor: isSelected ? AppColors.primaryColor : Colors.transparent,
          radius: 32,
        ),
        child: Text(tagName, style: TextStyles.bold13.copyWith(color: isSelected ? Colors.white : Colors.black),),
      ),
    );
  }
}

