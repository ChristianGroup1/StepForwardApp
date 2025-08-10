import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'اهلًا بك ${getUserData().firstName} 👋',
      style: TextStyles.bold16.copyWith(color: AppColors.primaryColor),
    );
  }
}
