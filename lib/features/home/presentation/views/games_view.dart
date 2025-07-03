import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/home_cubit/home_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/widgets/games_view_body.dart';

class GamesView extends StatelessWidget {
  const GamesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(getIt.get<HomeRepo>(), getIt.get<AuthRepo>())..getGames()..getUserApprovedDataIfNotApproved(),
      child: GamesViewBody(),
    );
  }
}
