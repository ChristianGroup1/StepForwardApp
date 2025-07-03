import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class CustomMoreAppBarWidget extends StatelessWidget {
  final String title;
  const CustomMoreAppBarWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primaryColor)),
       
        Text(
          title,
          style: TextStyles.bold23.copyWith(color: AppColors.primaryColor),
        ),
      ],
    );
  }
}