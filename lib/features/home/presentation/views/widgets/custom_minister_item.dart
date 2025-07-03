import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_box_decoration.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/my_divider.dart';

import '../../../../../core/utils/app_colors.dart';

class CustomMinisterItem extends StatelessWidget {
  const CustomMinisterItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8),
      padding: const EdgeInsets.all(8.0),
      decoration: customCardDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              Assets.assetsImagesStepForwardLogo,
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('الاخ بيتر فرحات', style: TextStyles.bold16),
                    Spacer(),
                    Icon(
                      Icons.phone_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
                MyDivider(),
                Text(
                  'متكلم',
                  style: TextStyles.bold13.copyWith(
                    color: Colors.grey,
                  ),
                ),
                verticalSpace(8),
                Text(
                  'خادم بكنيسة الانجيلية - المنيا',
                  style: TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace(8),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
