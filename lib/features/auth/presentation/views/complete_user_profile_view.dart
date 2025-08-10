import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/repos/image_repo.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/complete_profile_view_body.dart';

class CompleteUserProfileView extends StatelessWidget {
  final UserModel? user;
  const CompleteUserProfileView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignUpCubit(getIt.get<AuthRepo>(), getIt.get<ImagesRepo>()),
      child: Scaffold(body: CompleteUserProfileViewBody(user: user)),
    );
  }
}

