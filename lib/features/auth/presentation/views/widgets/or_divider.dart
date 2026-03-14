import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(context.isEn ? 'or' : 'أو'),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
