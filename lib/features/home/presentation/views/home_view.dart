import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/widgets/home_view_body.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              BrothersCubit(getIt.get<HomeRepo>(), getIt.get<AuthRepo>())..getUserApprovedDataIfNotApproved()..getBrothers(),
          ),
          BlocProvider(
            create: (context) => GamesCubit(getIt.get<HomeRepo>(), getIt.get<AuthRepo>())..getGames()..getBooks(),
          ),
      ],
      child: HomeViewBody(),
    );
  }
}
