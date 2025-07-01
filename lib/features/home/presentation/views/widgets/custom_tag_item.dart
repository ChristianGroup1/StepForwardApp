import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_box_decoration.dart';

class CustomTagItem extends StatelessWidget {
  final String tagName;
  const CustomTagItem({
    super.key,
    required this.tagName
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      alignment: Alignment.center,
      decoration: customBoxDecoration(
        mainColor: Colors.transparent,
        radius: 32,
      ),
      child: Text(tagName, style: TextStyles.semiBold13,),
    );
  }
}

