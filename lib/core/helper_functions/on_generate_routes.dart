import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/features/auth/presentation/views/login_view.dart';
import 'package:stepforward/features/home/presentation/views/main_view.dart';

Route onGenerateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case Routes.loginView:
      return PageTransition(
        duration: Duration(milliseconds: 50),
        child: const LoginView(),
        type: PageTransitionType.fade,
      );

    case Routes.mainView:
      return PageTransition(
        duration: Duration(milliseconds: 50),
        child: const MainView(),
        type: PageTransitionType.fade,
      );

    default:
      // var isLoggedIn = FirebaseAuthService().isLoggedIn();
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const MainView(),
        type: PageTransitionType.fade,
      );
  }
}
