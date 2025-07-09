import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/features/home/data/more_cubit/more_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/update_user_profile_button.dart';
import 'package:stepforward/features/home/presentation/views/widgets/update_user_profile_text_fields.dart';

class UpdateUserProfileViewBody extends StatefulWidget {
  const UpdateUserProfileViewBody({super.key});

  @override
  State<UpdateUserProfileViewBody> createState() => _UpdateUserProfileViewBodyState();
}

class _UpdateUserProfileViewBodyState extends State<UpdateUserProfileViewBody> {
  @override
  void initState() {
    var cubit = context.read<MoreCubit>();
    cubit.updatedFirstNameController.text = getUserData().firstName;
    cubit.updatedLastNameController.text = getUserData().lastName;
    cubit.updatedPhoneController.text = getUserData().phoneNumber;
    cubit.updatedChurchNameController.text = getUserData().churchName;
    cubit.updatedGovernmentController.text = getUserData().government;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<MoreCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kHorizontalPadding, vertical: kVerticalPadding),
      child: BlocConsumer<MoreCubit, MoreState>(
        listener: (context, state) {
          if (state is UpdateUserProfileSuccessState) {
            showSnackBar(context, text: 'تم التعديل بنجاح');
          } else if (state is UpdateUserProfileFailureState) {
            showSnackBar(context, text: state.errorMessage);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                verticalSpace(24.h),
                UpdateUserProfileTextFields(cubit: cubit),
                verticalSpace(48.h),
                state is UpdateUserProfileLoadingState
                    ? const Center(child: CustomAnimatedLoadingWidget())
                    : UpdateUserProfileButton(cubit: cubit),
              ],
            ),
          );
        },
      ),
    );
  }
}