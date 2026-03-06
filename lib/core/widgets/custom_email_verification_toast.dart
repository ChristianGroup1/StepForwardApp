import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_snak_bar.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';

class CustomEmailVerificationToast extends StatelessWidget {
  const CustomEmailVerificationToast({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrothersCubit, BrothersState>(
      buildWhen: (previous, current) =>
          current is CheckUserEmailVerification,
      builder: (context, state) {
        if (state is CheckUserEmailVerification && !state.isVerified) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'تم إرسال ايميل لتأكيد الحساب، راجع الإيميل من فضلك',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.regular14.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                horizontalSpace(8),
                OutlinedButton(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      user.sendEmailVerification();
                    }
                    showSnackBar(
                      context,
                      text: 'تم إعادة إرسال الإيميل بنجاح',
                      color: Colors.green,
                    );
                  },
                  child: Text(
                    'إعادة إرسال',
                    style: TextStyles.semiBold13.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
