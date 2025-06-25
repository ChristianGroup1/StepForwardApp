import 'package:flutter/material.dart';

double getAspectRatio(BuildContext context) {
  double width = MediaQuery.sizeOf(context).width;

  if (width > 600) {
    return 0.65;
  } else if (width <= 370) {
    return 0.53;
  } else {
    return 0.55;
  }
}

double getProductHeight(BuildContext context) {
  double height = MediaQuery.sizeOf(context).height;
  if (height < 750 ) {
    return 2.3;
  } else if (height <= 1000) {
    return 2.9;
  } else {
    return 2.7;
  }
}