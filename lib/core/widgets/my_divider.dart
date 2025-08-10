import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final double? thickness;
  final double? height;
  const MyDivider({super.key, this.indent, this.endIndent, this.thickness,this.height});

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness ?? 1.5,
      color: Colors.grey[300],
      endIndent: endIndent ?? 20,
      indent: indent ?? 20,
      height: height?? 40,
    );
  }
}
