import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/app_regex.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_drop_down_form_field.dart';
import 'package:stepforward/core/widgets/custom_text_field.dart';
import 'package:stepforward/core/widgets/governments_list.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/data/sign_up_cubit/sign_up_cubit.dart';
import 'package:stepforward/features/auth/presentation/views/widgets/image_field.dart';

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
    return Column(
      children: [
        CustomTextFormField(
          textInputType: TextInputType.name,
          initialValue: widget.user?.firstName,

          labelText: widget.user?.firstName == null ? 'الاسم الاول' : null,
          // hintText: user?.firstName=='' ? null : user?.firstName,
          onChanged: (value) {
            widget.cubit.firstNameController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          textInputType: TextInputType.name,
          initialValue: widget.user?.lastName,

          labelText: widget.user?.lastName == null ? 'الاسم الاخير' : null,
          //hintText: user?.lastName=='' ? null : user?.lastName,
          onChanged: (value) {
            widget.cubit.secondNameController.text = value;
          },
        ),
        verticalSpace(24),
        CustomTextFormField(
          isEnabled: widget.user?.email == null ? true : false,
          textInputType: TextInputType.emailAddress,
          initialValue: widget.user?.email,

          labelText: widget.user?.email == null ? 'البريد الإلكتروني' : null,
          //hintText: user?.email=='' ? null : user?.email,
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
          labelText: 'اسم الكنيسة',
          onChanged: (value) {
            widget.cubit.churchNameController.text = value;
          },
        ),
        verticalSpace(24),
        ImageField(
          onChanged: (value) {
            widget.cubit.frontId = value;
          },
          text: 'وجه البطاقة',
        ),
        verticalSpace(24),
        ImageField(
          onChanged: (value) {
            widget.cubit.backId = value;
          },
          text: 'ظهر البطاقة',
        ),
        verticalSpace(24),
        CustomTextFormField(
          textInputType: TextInputType.phone,
          initialValue: widget.user?.phoneNumber,
          labelText: 'رقم الهاتف' ,

          // hintText: widget.user?.phoneNumber=='' ? null : widget.user?.phoneNumber,
          onChanged: (value) {
            widget.cubit.phoneNumberController.text = value;
          },
          validator: (value) {
            if (!AppRegex.isPhoneNumberValid(value!)) {
              return 'رقم الهاتف غير صالح';
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
          labelText: 'كلمة المرور',
          onChanged: (value) {
            widget.cubit.passwordController.text = value;
          },
        ),
        verticalSpace(48),
      ],
    );
  }
}
