import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_box_decoration.dart';
import 'package:stepforward/core/utils/spacing.dart';

class CustomDenominationItem extends StatelessWidget {
  final String denomination;
  final VoidCallback onTap;

  const CustomDenominationItem({
    super.key,
    required this.denomination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        decoration: customBoxDecoration(mainColor: Colors.transparent, radius: 32),
        child: Row(
          children: [
            const Icon(Icons.church, color: AppColors.primaryColor),
            horizontalSpace(4),
            Text(
              '${isEn ? "Denomination" : "الطائفة"}: $denomination',
              style: TextStyles.bold13.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
