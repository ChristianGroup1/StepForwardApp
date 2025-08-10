import 'package:flutter/material.dart';

class CustomMoreViewListTileItem extends StatelessWidget {
  final Text? title;
  final Widget? leading;
  final Widget? trailing;
  final void Function()? onTap;
  const CustomMoreViewListTileItem({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      trailing: trailing,
      onTap: onTap,
    );
  }
}