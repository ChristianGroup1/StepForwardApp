import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/cubits/locale_cubit.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';

/// Compact AR / EN toggle shown on pre-login screens (login, sign-up,
/// forgot-password).  Reads and writes [LocaleCubit] which is provided
/// at the root of the app.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isEn = locale.languageCode == 'en';
        return Align(
          alignment: AlignmentDirectional.topEnd,
          child: Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
              ),
              icon: const Icon(
                Icons.language,
                size: 16,
                color: AppColors.primaryColor,
              ),
              label: Text(
                isEn ? 'عربي' : 'English',
                style: TextStyles.semiBold13
                    .copyWith(color: AppColors.primaryColor),
              ),
              onPressed: () {
                context
                    .read<LocaleCubit>()
                    .changeLocale(isEn ? 'ar' : 'en');
              },
            ),
          ),
        );
      },
    );
  }
}
