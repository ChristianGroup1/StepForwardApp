 import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

AppBar buildAppBar(context, {required String title,void Function()?onTap,bool visibleLeading=true,List<Widget>? actions}) {
    return AppBar(
      forceMaterialTransparency: true,
      leading:visibleLeading? GestureDetector(
        onTap:onTap ,
        child: const Icon(Icons.arrow_back_ios)):const SizedBox.shrink(),
      centerTitle: true,
      actions: actions ,
      title: Text(title, style: TextStyles.bold19,),
    );
  }