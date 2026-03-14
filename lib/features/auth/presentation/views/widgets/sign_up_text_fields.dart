import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/app_regex.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_drop_down_form_field.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/core/widgets/governments_list.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';

class SignUpTextFields extends StatefulWidget {
  const SignUpTextFields({super.key, required this.cubit, this.user});
  final UserModel? user;
  final SignUpCubit cubit;

  @override
  State<SignUpTextFields> createState() => _SignUpTextFieldsState();
}

class _SignUpTextFieldsState extends State<SignUpTextFields> {
  @override
  void initState() {
    if (widget.user != null) {
      widget.cubit.firstNameController.text = widget.user!.firstName;
      widget.cubit.secondNameController.text = widget.user!.lastName;
      widget.cubit.emailController.text = widget.user!.email;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return Column(
      children: [
        CustomTextFormField(
          textInputType: TextInputType.name,
          initialValue: widget.user?.firstName,
          labelText: widget.user?.firstName == null
              ? (isEn ? 'First Name' : 'الاسم الاول')
              : null,
          onChanged: (value) {
            widget.cubit.firstNameController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          textInputType: TextInputType.name,
          initialValue: widget.user?.lastName,
          labelText: widget.user?.lastName == null
              ? (isEn ? 'Last Name' : 'الاسم الاخير')
              : null,
          onChanged: (value) {
            widget.cubit.secondNameController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          isEnabled: widget.user?.email == null ? true : false,
          textInputType: TextInputType.emailAddress,
          initialValue: widget.user?.email,
          labelText: widget.user?.email == null
              ? (isEn ? 'Email' : 'البريد الإلكتروني')
              : null,
          onChanged: (value) {
            widget.cubit.emailController.text = value;
          },
        ),
        verticalSpace(24),
        CustomDropDownButtonFormField(
          onChanged: (value) {
            widget.cubit.governmentController.text = value!;
          },
          items: governments
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
        ),
        verticalSpace(24),
        CustomTextFormField(
          labelText: isEn ? 'Church Name' : 'اسم الكنيسة',
          onChanged: (value) {
            widget.cubit.churchNameController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          textInputType: TextInputType.phone,
          initialValue: widget.user?.phoneNumber,
          labelText: isEn ? 'Phone Number' : 'رقم الهاتف',
          onChanged: (value) {
            widget.cubit.phoneNumberController.text = value;
          },
          validator: (value) {
            if (!AppRegex.isPhoneNumberValid(value!)) {
              return isEn ? 'Invalid phone number' : 'رقم الهاتف غير صالح';
            }
            return null;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          suffixIcon: GestureDetector(
            onTap: () => widget.cubit.changePasswordVisibility(),
            child: widget.cubit.suffixIcon,
          ),
          isObscured: widget.cubit.isObscured,
          labelText: isEn ? 'Password' : 'كلمة المرور',
          onChanged: (value) {
            widget.cubit.passwordController.text = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return isEn ? 'This field is required' : 'هذا الحقل مطلوب';
            } else if (!AppRegex.isPasswordValid(value)) {
              return isEn
                  ? 'Password must be at least 8 characters,\nincluding uppercase, lowercase\nand a symbol like @ or !'
                  : 'كلمة المرور يجب أن لا تقل عن 8 حروف وارقام،\n وتشمل حرف كبير، حرف صغير\n ورمز مثل @ أو !';
            }
            return null;
          },
        ),
        verticalSpace(48),
      ],
    );
  }
}
