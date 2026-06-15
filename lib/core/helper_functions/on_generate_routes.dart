import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/presentation/views/complete_user_profile_view.dart';
import 'package:stepforward/features/auth/presentation/views/forget_password_view.dart';
import 'package:stepforward/features/auth/presentation/views/login_view.dart';
import 'package:stepforward/features/auth/presentation/views/sign_up_view.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';
import 'package:stepforward/features/home/presentation/views/book_view.dart';
import 'package:stepforward/features/home/presentation/views/favorites_view.dart';
import 'package:stepforward/features/home/presentation/views/game_details.dart';
import 'package:stepforward/features/home/presentation/views/game_details_by_id_view.dart';
import 'package:stepforward/features/home/presentation/views/main_view.dart';
import 'package:stepforward/features/home/presentation/views/preparation_checklist_view.dart';
import 'package:stepforward/features/home/presentation/views/service_history_view.dart';
import 'package:stepforward/features/home/presentation/views/team_members_view.dart';
import 'package:stepforward/features/home/presentation/views/team_preparation_view.dart';
import 'package:stepforward/features/home/presentation/views/team_service_history_view.dart';
import 'package:stepforward/features/home/presentation/views/team_splitter_view.dart';
import 'package:stepforward/features/home/presentation/views/team_workspace_view.dart';
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
    case Routes.preparationChecklistView:
      AnalyticsService.logScreenView(screenName: 'PreparationChecklistView');

      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const PreparationChecklistView(),
        type: PageTransitionType.fade,
      );
    case Routes.teamSplitterView:
      AnalyticsService.logScreenView(screenName: 'TeamSplitterView');

      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const TeamSplitterView(),
        type: PageTransitionType.fade,
      );
    case Routes.serviceHistoryView:
      AnalyticsService.logScreenView(screenName: 'ServiceHistoryView');

      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const ServiceHistoryView(),
        type: PageTransitionType.fade,
      );
    case Routes.teamWorkspaceView:
      AnalyticsService.logScreenView(screenName: 'TeamWorkspaceView');
      final inviteCode = settings.arguments is String
          ? settings.arguments as String
          : null;

      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: TeamWorkspaceView(initialInviteCode: inviteCode),
        type: PageTransitionType.fade,
      );
    case Routes.teamPreparationView:
      AnalyticsService.logScreenView(screenName: 'TeamPreparationView');
      final team = settings.arguments as TeamWorkspaceModel;
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: TeamPreparationView(team: team),
        type: PageTransitionType.fade,
      );
    case Routes.teamServiceHistoryView:
      AnalyticsService.logScreenView(screenName: 'TeamServiceHistoryView');
      final team = settings.arguments as TeamWorkspaceModel;
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: TeamServiceHistoryView(team: team),
        type: PageTransitionType.fade,
      );
    case Routes.teamMembersView:
      AnalyticsService.logScreenView(screenName: 'TeamMembersView');
      final team = settings.arguments as TeamWorkspaceModel;
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: TeamMembersView(team: team),
        type: PageTransitionType.fade,
      );
    case Routes.uploadIdView:
      AnalyticsService.logScreenView(screenName: 'UploadIdView');
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: const UploadUserIdView(),
        type: PageTransitionType.fade,
      );

    case Routes.gameDetailsById:
      final gameId = settings.arguments as String;
      AnalyticsService.logScreenView(screenName: 'GameDetailsByIdView');
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: GameDetailsByIdView(gameId: gameId),
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
      var isLoggedIn = hasCachedUserData();
      return PageTransition(
        duration: const Duration(milliseconds: 50),
        child: isLoggedIn ? const MainView() : const LoginView(),
        type: PageTransitionType.fade,
      );
  }
}
