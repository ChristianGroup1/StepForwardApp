import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/services/firebase_auth_service.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/presentation/views/complete_user_profile_view.dart';
import 'package:stepforward/features/auth/presentation/views/forget_password_view.dart';
import 'package:stepforward/features/auth/presentation/views/login_view.dart';
import 'package:stepforward/features/auth/presentation/views/sign_up_view.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/presentation/views/book_view.dart';
import 'package:stepforward/features/home/presentation/views/favorites_view.dart';
import 'package:stepforward/features/home/presentation/views/game_details.dart';
import 'package:stepforward/features/home/presentation/views/main_view.dart';
import 'package:stepforward/features/home/presentation/views/update_user_profile_view.dart';
import 'package:stepforward/features/home/presentation/views/upload_user_id_view.dart';

Route onGenerateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case Routes.loginView:
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const LoginView(),
        type: PageTransitionType.fade,
      );

    case Routes.signUpView:
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const SignUpView(),
        type: PageTransitionType.fade,
      );

    case Routes.forgetPasswordView:
      AnalyticsService.logScreenView(screenName: 'ForgetPasswordView');
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const ForgetPasswordView(),
        type: PageTransitionType.fade,
      );
    case Routes.completeUserProfileView:
      var userModel = settings.arguments as UserModel;
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: CompleteUserProfileView(user: userModel),
        type: PageTransitionType.fade,
      );
    case Routes.mainView:
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const MainView(),
        type: PageTransitionType.fade,
      );

    case Routes.gameDetails:
      final game = settings.arguments as GameModel;
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: GameDetails(game: game),
        type: PageTransitionType.fade,
      );
    case Routes.updateUserProfile:
      AnalyticsService.logScreenView(screenName: 'UpdateUserProfileView');

      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const UpdateUserProfileView(),
        type: PageTransitionType.fade,
      );

    case Routes.favoritesView:
      AnalyticsService.logScreenView(screenName: 'FavoritesView');

      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const FavoritesView(),
        type: PageTransitionType.fade,
      );
    case Routes.uploadIdView:
      AnalyticsService.logScreenView(screenName: 'UploadIdView');
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const UploadUserIdView(),
        type: PageTransitionType.fade,
      );
    case Routes.pdfViewerScreen:
      AnalyticsService.logScreenView(screenName: 'PdfViewerScreen');
      final args = settings.arguments as Map<String, dynamic>;
      final title = args['title'];
      final url = args['url'];
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: PdfViewerScreen(title: title, url: url),
        type: PageTransitionType.fade,
      );

    default:
      var isLoggedIn =
          FirebaseAuthService().isLoggedIn() ||
          CacheHelper.getData(key: kSaveUserDataKey) != null;
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: isLoggedIn ? const MainView() : const LoginView(),
        type: PageTransitionType.fade,
      );
  }
}
