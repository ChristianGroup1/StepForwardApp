import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

AppBar buildAppBar(
  context, {
  required String title,
  void Function()? onTap,
  bool visibleLeading = true,
  List<Widget>? actions,
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  final appBarBackgroundColor =
      backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
  final appBarForegroundColor =
      foregroundColor ?? Theme.of(context).colorScheme.onSurface;

  return AppBar(
    backgroundColor: appBarBackgroundColor,
    foregroundColor: appBarForegroundColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: appBarBackgroundColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    leading: visibleLeading
        ? GestureDetector(onTap: onTap, child: const Icon(Icons.arrow_back_ios))
        : const SizedBox.shrink(),
    centerTitle: true,
    actions: actions,
    title: Text(
      title,
      style: TextStyles.bold19.copyWith(color: appBarForegroundColor),
    ),
  );
}
