import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/widgets/brothers_view_body.dart';

class BrothersView extends StatelessWidget {
  const BrothersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BrothersCubit(getIt.get<HomeRepo>(),  // Injecting HomeRepo
              getIt.get<AuthRepo>()) // Injecting AuthRepo
            ..getBrothers()..getUserApprovedDataIfNotApproved(),
      child: BrothersViewBody(),
    );
  }
}
