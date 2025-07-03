import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/widgets/custom_button.dart';
import 'package:stepforward/features/home/data/more_cubit/more_cubit.dart';


class UpdateUserProfileButton extends StatelessWidget {
  const UpdateUserProfileButton({
    super.key,
    required this.cubit,
  });

  final MoreCubit cubit;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
        backgroundColor: cubit.hasChanges
            ? AppColors.primaryColor
            : Colors.grey,
        text: 'حفظ',
        onPressed: (){
          
          cubit.hasChanges
              ? cubit.updateUserData(
                 
                )
              : showSnackBar(context, text: 'لا يوجد تغييرات');
        });
  }
}