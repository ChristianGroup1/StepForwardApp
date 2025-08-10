import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/widgets/home_view_body.dart';

class HomeView extends StatelessWidget {
  final VoidCallback onNavigateToGamesView;
  final VoidCallback onNavigateToBrothersView;

  const HomeView({
    super.key,
    required this.onNavigateToGamesView,
    required this.onNavigateToBrothersView,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              BrothersCubit(getIt.get<HomeRepo>(), getIt.get<AuthRepo>())
                ..checkAndToastIfNotVerified()
                ..getUserApprovedDataIfNotApproved()
                ..getBrothers(),
        ),
        BlocProvider(
          create: (context) =>
              GamesCubit(getIt.get<HomeRepo>(), getIt.get<AuthRepo>())
                ..getGames()
                ..getBooks(),
        ),
      ],
      child: Builder(
        builder: (context) {
          var cubit = context.read<BrothersCubit>();
          return RefreshIndicator(
            backgroundColor: Colors.white,
            onRefresh: () async {
              await context.read<BrothersCubit>().getBrothers();
              await context.read<GamesCubit>().getGames();
              await context.read<GamesCubit>().getBooks();
              cubit.checkAndToastIfNotVerified();
            },
            child: HomeViewBody(
              onNavigateToGamesView: onNavigateToGamesView,
              onNavigateToBrothersView: onNavigateToBrothersView,
            ),
          );
        },
      ),
    );
  }
}
