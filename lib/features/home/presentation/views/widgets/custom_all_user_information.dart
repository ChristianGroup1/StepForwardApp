import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_user_information_item.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';


class CustomAllUserInformation extends StatelessWidget {
  const CustomAllUserInformation({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          CustomUserInformationItem(
            title: 'رقم الهاتف: ',
            value: user.phoneNumber.toString(),
          ),
          verticalSpace(12),
          
    
          CustomUserInformationItem(
            title: 'كنيسة: ',
            value: user.churchName.toString(),
          ),
          verticalSpace(12),
          CustomUserInformationItem(
            title: 'محافظة: ',
            value: user.government.toString(),
          ),
        ],
      ),
    );
  }
}