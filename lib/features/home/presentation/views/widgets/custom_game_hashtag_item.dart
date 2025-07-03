import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

class CustomGameHashTagItem extends StatelessWidget {
  final String tagName;
  const CustomGameHashTagItem({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD6D6D6)),
      ),
      child: Text(
        '#$tagName',
        style: TextStyles.semiBold13.copyWith(
          color: const Color(0xff5A5A5A),
        ),
      ),
    );
  }
}
