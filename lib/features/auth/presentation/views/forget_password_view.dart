import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/widgets/custom_app_bar.dart';
import 'package:stepforward/core/widgets/language_toggle_button.dart';
import 'package:stepforward/features/auth/data/login_cubit/login_cubit.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/email_reset_password_view_body.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return BlocProvider(
      create: (context) => LoginCubit(getIt.get<AuthRepo>()),
      child: Scaffold(
        appBar: buildAppBar(
          context,
          title: isEn ? 'Reset Password' : 'اعادة تعيين كلمة المرور',
          onTap: () => context.pop(),
          actions: const [LanguageToggleButton()],
        ),
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is SendEmailToResetPasswordSuccessState) {
              showSnackBar(
                context,
                text: context.isEn
                    ? 'Password reset email sent successfully'
                    : 'تم ارسال البريد الالكتروني لاعادة التعيين',
                color: Colors.green,
              );
            }
            if (state is SendEmailToResetPasswordFailureState) {
              showSnackBar(
                context,
                text: state.errMessage,
                color: Colors.red,
              );
            }
          },
          child: const EmailResetPasswordViewBody(),
        ),
      ),
    );
  }
}
