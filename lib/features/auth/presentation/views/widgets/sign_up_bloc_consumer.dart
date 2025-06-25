import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/sign_up_view_body.dart';

class SignUpBlocConsumer extends StatelessWidget {
  const SignUpBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<SignUpCubit>();
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccessState) {
          context.pushReplacementNamed(Routes.mainView);
        }
        if (state is SignUpFailureState) {
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
        return ModalProgressHUD(
          inAsyncCall: state is SignUpLoadingState,
          progressIndicator: CustomAnimatedLoadingWidget(),
          blur: 1.5,
          child: SignUpViewBody(cubit: cubit),
        );
      },
    );
  }
}


