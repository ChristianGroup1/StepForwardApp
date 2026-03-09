import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:stepforward/core/cubits/language_cubit.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/delete_account_quick_alret_dialogs.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/helper_functions/show_about_us_dialog.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_more_list_tile_item.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/data/more_cubit/more_cubit.dart';
import 'package:stepforward/generated/l10n.dart';

class CustomMoreViewListTileActions extends StatelessWidget {
  const CustomMoreViewListTileActions({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomMoreViewListTileItem(
            title: Text(s.favorites, style: TextStyles.bold16),
            leading: const Icon(Icons.favorite, color: AppColors.primaryColor),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              context.pushNamed(Routes.favoritesView);
            },
          ),
          const MyDivider(),
          CustomMoreViewListTileItem(
            title: Text(s.editProfile, style: TextStyles.bold16),
            leading: const Icon(Icons.person, color: AppColors.primaryColor),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryColor,
            ),
            onTap: () => context.pushNamed(Routes.updateUserProfile),
          ),
          const MyDivider(),

          CustomMoreViewListTileItem(
            title: Text(s.resetPassword, style: TextStyles.bold16),
            leading: const Icon(
              Icons.password_rounded,
              color: AppColors.primaryColor,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryColor,
            ),
            onTap: () => context.pushNamed(Routes.forgetPasswordView),
          ),
          const MyDivider(),
          CustomMoreViewListTileItem(
            title: Text(s.aboutUs, style: TextStyles.bold16),
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.primaryColor,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              showAboutUsDialog(context);
            },
          ),
          const MyDivider(),

          // Language Selector
          BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              final isArabic = locale.languageCode == 'ar';
              return CustomMoreViewListTileItem(
                title: Text(s.language, style: TextStyles.bold16),
                leading: const Icon(
                  Icons.language,
                  color: AppColors.primaryColor,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LanguageButton(
                      label: 'ع',
                      isSelected: isArabic,
                      onTap: () =>
                          context.read<LanguageCubit>().changeLanguage('ar'),
                    ),
                    horizontalSpace(8),
                    _LanguageButton(
                      label: 'EN',
                      isSelected: !isArabic,
                      onTap: () =>
                          context.read<LanguageCubit>().changeLanguage('en'),
                    ),
                  ],
                ),
                onTap: null,
              );
            },
          ),

          const Divider(),
          CustomMoreViewListTileItem(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              s.logout,
              style: TextStyles.bold16.copyWith(color: Colors.red),
            ),
            onTap: () {
              customQuickAlertView(
                context,
                text: s.logoutConfirmText,
                title: s.logoutConfirmTitle,
                confirmBtnText: s.yes,

                type: QuickAlertType.warning,
                onConfirmBtnTap: () async {
                  await context.read<MoreCubit>().signOut();
                  context.pushNamedAndRemoveUntil(
                    Routes.loginView,
                    predicate: (route) => false,
                  );
                },
              );
            },
          ),
          const Divider(),

          // Delete Account
          CustomMoreViewListTileItem(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              s.deleteAccount,
              style: TextStyles.bold16.copyWith(color: Colors.red),
            ),
            onTap: () {
              customQuickAlertView(
                context,
                text: s.deleteAccountText,
                title: s.deleteAccountTitle,
                confirmBtnText: s.yes,

                type: QuickAlertType.warning,
                onConfirmBtnTap: () async {
                  final accountCubit = context.read<MoreCubit>();

                  final user = await accountCubit.getCurrentUser();

                  final bool isEmailUser =
                      user.providerData.first.providerId == 'password';

                  if (isEmailUser) {
                    showPasswordQuickAlert(context, accountCubit);
                  } else {
                    confirmDeleteAccount(context, accountCubit, null);
                  }
                },
              );
            },
          ),
          verticalSpace(24.h),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyles.bold13.copyWith(
            color: isSelected ? Colors.white : AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

