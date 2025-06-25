import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
        children: [
        Expanded(child: Divider()),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('أو',),
        ),
        Expanded(child: Divider())
      ],);
  }
}