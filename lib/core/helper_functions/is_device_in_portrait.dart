import 'package:flutter/material.dart';

bool isDeviceInPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait ? true : false;
  }