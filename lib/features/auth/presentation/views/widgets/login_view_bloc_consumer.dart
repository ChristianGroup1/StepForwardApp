import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/features/auth/data/login_cubit/login_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/login_view_body.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class LoginViewBlocConsumer extends StatelessWidget {
  const LoginViewBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          context.pushReplacementNamed(Routes.mainView);
        }
        if (state is LoginFailureState) {
          customQuickAlertView(
            context,
            text: state.errorMessage,
            title: 'حدث خطأ',
            confirmBtnText: 'حسنا',
            type: QuickAlertType.error,
            onConfirmBtnTap: () {
              context.pop();
            },
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
        return ModalProgressHUD(
          inAsyncCall: state is LoginLoadingState,
          progressIndicator: CustomAnimatedLoadingWidget(),
          blur: 1.5,
          child: LoginViewBody(cubit: cubit),
        );
      },
    );
  }
}

