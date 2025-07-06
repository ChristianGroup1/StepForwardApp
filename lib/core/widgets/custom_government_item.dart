import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_box_decoration.dart';
import 'package:stepforward/core/utils/spacing.dart';

class CustomGovernorateTagItem extends StatelessWidget {
  final String governorate;
 
  final VoidCallback onTap;

  const CustomGovernorateTagItem({
    super.key,
    required this.governorate,
    
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        decoration: customBoxDecoration(
          mainColor: Colors.transparent,
          radius: 32,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryColor,
            ),
            horizontalSpace(4),
            Text(
              'المحافظة : $governorate',
              style: TextStyles.bold13.copyWith(
                color:  Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
