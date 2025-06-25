import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(child: Text('Main View ${getUserData().phoneNumber}')),
    );
  }
}