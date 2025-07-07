import 'package:flutter/material.dart';
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
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
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
            ? ChatBotFloatingButton()
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
            GamesView(),
            BrothersView(),
            MoreView(),
          ],
        ),
      ),
    );
  }
}
