import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/auth/data/login_cubit/login_cubit.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/login_view_bloc_consumer.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => LoginCubit(getIt.get<AuthRepo>()),
        child: const Scaffold(body: LoginViewBlocConsumer()),
      ),
    );
  }
}
