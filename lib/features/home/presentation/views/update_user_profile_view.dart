import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/more_cubit/more_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/update_user_profile_view_body.dart';

class UpdateUserProfileView extends StatelessWidget {
  const UpdateUserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoreCubit(getIt.get<AuthRepo>()),
      child: const Scaffold(body: UpdateUserProfileViewBody()),
    );
  }
}
