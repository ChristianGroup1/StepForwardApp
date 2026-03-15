import 'package:flutter/material.dart';
import 'package:stepforward/core/services/analytics_service.dart';
import 'package:stepforward/core/services/deep_link_service.dart';
import 'package:stepforward/core/widgets/custom_buttom_navigation_bar.dart';
import 'package:stepforward/core/widgets/custom_floating_action_button.dart';
import 'package:stepforward/features/home/presentation/views/home_view.dart';
import 'package:stepforward/features/home/presentation/views/brothers_view.dart';
import 'package:stepforward/features/home/presentation/views/games_view.dart';
import 'package:stepforward/features/home/presentation/views/more_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    // Navigate to any game that was requested via a deep link before the
    // user authenticated (e.g. cold-start while not logged in).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) DeepLinkService.navigatePendingIfAny(context);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    String screenName;
    switch (index) {
      case 0:
        screenName = 'HomeView';
        break;
      case 1:
        screenName = 'GamesView';
        break;
      case 2:
        screenName = 'BrothersView';
        break;
      case 3:
        screenName = 'MoreView';
        break;
      default:
        screenName = 'UnknownView';
    }

    AnalyticsService.logScreenView(screenName: screenName);
  }

  void navigateToGamesView() {
    _onItemTapped(1);
  }

  void navigateToBrothersView() {
    _onItemTapped(2);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

        floatingActionButton: selectedIndex == 0
            ? const ChatBotFloatingButton()
            : null,

        bottomNavigationBar: CustomButtonNavigationBar(
          onItemTapped: _onItemTapped,
          selectedIndex: selectedIndex,
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: [
            HomeView(
              onNavigateToGamesView: navigateToGamesView,
              onNavigateToBrothersView: navigateToBrothersView,
            ),
            const GamesView(),
            const BrothersView(),
            const MoreView(),
          ],
        ),
      ),
    );
  }
}
