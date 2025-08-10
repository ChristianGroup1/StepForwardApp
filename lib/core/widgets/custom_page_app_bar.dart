import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class CustomPageAppBar extends StatelessWidget {
  final String title;
  const CustomPageAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyles.bold19,
      ),
    );
  }
}