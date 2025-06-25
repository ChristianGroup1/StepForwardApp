import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_drop_down_form_field.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/core/widgets/governments_list.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/image_field.dart';

class SignUpTextFields extends StatelessWidget {
  const SignUpTextFields({
    super.key,
    required this.cubit,
  });

  final SignUpCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          textInputType: TextInputType.name,
          labelText: 'الاسم الاول',
          onChanged: (value) {
            cubit.firstNameController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          textInputType: TextInputType.name,
          labelText: 'الاسم الاخير',
          onChanged: (value) {
            cubit.secondNameController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          textInputType: TextInputType.emailAddress,
          labelText: 'البريد الإلكتروني',
          onChanged: (value) {
            cubit.emailController.text = value;
          },
        ),
        verticalSpace(24),
        CustomDropDownButtonFormField(
          onChanged: (value) {
            cubit.governmentController.text = value!;
          },
          items: governments
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
        ),
        verticalSpace(24),
        CustomTextFormField(
          labelText: 'اسم الكنيسة',
          onChanged: (value) {
            cubit.churchNameController.text = value;
          },
        ),
        verticalSpace(24),
        ImageField(
          onChanged: (value) {
            cubit.frontId = value;
          },
          text: 'وجه البطاقة',
        ),
        verticalSpace(24),
        ImageField(
          onChanged: (value) {
            cubit.backId = value;
          },
          text: 'ظهر البطاقة',
        ),
        verticalSpace(24),
        CustomTextFormField(
          textInputType: TextInputType.phone,
          labelText: 'رقم الهاتف',
          onChanged: (value) {
            cubit.phoneNumberController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          suffixIcon: GestureDetector(
            onTap: () => cubit.changePasswordVisibility(),
            child: cubit.suffixIcon),
          isObscured: cubit.isObscured,
          labelText: 'كلمة المرور',
          onChanged: (value) {
            cubit.passwordController.text = value;
          },
        ),
        verticalSpace(48),
      ],
    );
  }
}
