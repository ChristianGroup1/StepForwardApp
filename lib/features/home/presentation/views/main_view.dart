import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/core/widgets/custom_buttom_navigation_bar.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/home_cubit/home_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/home_view.dart';
import 'package:stepforward/features/home/presentation/views/ministers_view.dart';
import 'package:stepforward/features/home/presentation/views/games_view.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) =>
            HomeCubit(getIt.get<HomeRepo>(), getIt.get<AuthRepo>())
              ..getUserApprovedDataIfNotApproved(),
        child: Scaffold(
          bottomNavigationBar: CustomButtonNavigationBar(
            onItemTapped: _onItemTapped,
            selectedIndex: selectedIndex,
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: const [
              HomeView(),
              GamesView(),
              MinistersView(),
              HomeView(),
            ],
          ),
        ),
      ),
    );
  }
}
