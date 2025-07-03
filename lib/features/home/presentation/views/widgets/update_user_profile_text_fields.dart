import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/helper_functions/app_regex.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_more_app_bar_widget.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/features/home/data/more_cubit/more_cubit.dart';


class UpdateUserProfileTextFields extends StatelessWidget {
  const UpdateUserProfileTextFields({
    super.key,
    required this.cubit,
  });

  final MoreCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomMoreAppBarWidget(
          title:  'تعديل البيانات الشخصية',
        ),
        verticalSpace(16.h),
        CustomTextFormField(
          textInputType: TextInputType.name,
          hintText: getUserData().firstName,
          controller: cubit.updatedFirstNameController,
          onChanged: (value) {
            cubit.userMakeChanges();

            cubit.updatedFirstNameController.text = value.trim();
          },
        ),
        verticalSpace(16.h),
       
        CustomTextFormField(
          textInputType: TextInputType.name,
          hintText: getUserData().lastName,
          controller: cubit.updatedLastNameController,
          onChanged: (value) {
            cubit.userMakeChanges();

            cubit.updatedLastNameController.text = value.trim();
          },
        ),
         verticalSpace(16.h),
        CustomTextFormField(
            textInputType: TextInputType.text,
            controller: cubit.updatedChurchNameController,
            onChanged: (value) {
              cubit.userMakeChanges();
              cubit.updatedChurchNameController.text = value.trim();
            },
            hintText: getUserData().churchName),
        verticalSpace(16.h),
        CustomTextFormField(
          textInputType: TextInputType.phone,
          hintText: getUserData().phoneNumber,
          controller: cubit.updatedPhoneController,
          onChanged: (value) {
            cubit.userMakeChanges();
            cubit.updatedPhoneController.text = value.trim();
          },
          validator: (value) {
            if(!AppRegex.isPhoneNumberValid(value!)) {
              return 'رقم الهاتف غير صالح';
            }
            return null;
          },
        ),
      ],
    );
  }
}

