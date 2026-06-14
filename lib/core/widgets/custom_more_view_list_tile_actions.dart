import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:stepforward/core/cubits/locale_cubit.dart';
import 'package:stepforward/core/cubits/theme_cubit.dart';
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

class CustomMoreViewListTileActions extends StatelessWidget {
  const CustomMoreViewListTileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isEn = locale.languageCode == 'en';
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Favorites
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'Favorites' : 'المفضلة',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.favorite,
                  color: AppColors.primaryColor,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onTap: () => context.pushNamed(Routes.favoritesView),
              ),
              const MyDivider(),
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'Preparation List' : 'قائمة التحضير',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.primaryColor,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onTap: () => context.pushNamed(Routes.preparationChecklistView),
              ),
              const MyDivider(),
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'Team Splitter' : 'تقسيم المجموعات',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.primaryColor,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onTap: () => context.pushNamed(Routes.teamSplitterView),
              ),
              const MyDivider(),
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'Old Services' : 'خدمات قديمة',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primaryColor,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onTap: () => context.pushNamed(Routes.serviceHistoryView),
              ),
              const MyDivider(),
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'My Team' : 'فريقي',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.group_work_rounded,
                  color: AppColors.primaryColor,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onTap: () => context.pushNamed(Routes.teamWorkspaceView),
              ),
              const MyDivider(),
              // Edit Profile
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'Edit Profile' : 'تعديل الملف الشخصي',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.person,
                  color: AppColors.primaryColor,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onTap: () => context.pushNamed(Routes.updateUserProfile),
              ),
              const MyDivider(),
              // Reset Password
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'Reset Password' : 'اعادة تعيين كلمة المرور',
                  style: TextStyles.bold16,
                ),
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
              // Theme Toggle
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  final isDark = themeMode == ThemeMode.dark;
                  return CustomMoreViewListTileItem(
                    title: Text(
                      isEn ? 'Dark Mode' : 'الوضع الداكن',
                      style: TextStyles.bold16,
                    ),
                    leading: const Icon(
                      Icons.dark_mode_outlined,
                      color: AppColors.primaryColor,
                    ),
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: AppColors.primaryColor,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme(value);
                      },
                    ),
                  );
                },
              ),
              const MyDivider(),
              // Language Toggle
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'Language' : 'اللغة',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.language,
                  color: AppColors.primaryColor,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEn ? 'English' : 'عربي',
                      style: TextStyles.semiBold13.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: isEn,
                      activeThumbColor: AppColors.primaryColor,
                      onChanged: (switchedToEn) {
                        context.read<LocaleCubit>().changeLocale(
                          switchedToEn ? 'en' : 'ar',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const MyDivider(),
              // About Us
              CustomMoreViewListTileItem(
                title: Text(
                  isEn ? 'About Us' : 'من نحن',
                  style: TextStyles.bold16,
                ),
                leading: const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onTap: () => showAboutUsDialog(context),
              ),
              const Divider(),
              // Sign Out
              CustomMoreViewListTileItem(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  isEn ? 'Sign Out' : 'تسجيل الخروج',
                  style: TextStyles.bold16.copyWith(color: Colors.red),
                ),
                onTap: () {
                  customQuickAlertView(
                    context,
                    text: isEn
                        ? 'Do you want to sign out?'
                        : 'هل تريد تسجيل الخروج؟',
                    title: isEn ? 'Sign Out' : 'تسجيل الخروج',
                    confirmBtnText: isEn ? 'Yes' : 'نعم',
                    type: QuickAlertType.warning,
                    onConfirmBtnTap: () async {
                      final moreCubit = context.read<MoreCubit>();
                      await moreCubit.signOut();
                      if (!context.mounted) return;
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
                  isEn ? 'Delete Account' : 'حذف الحساب',
                  style: TextStyles.bold16.copyWith(color: Colors.red),
                ),
                onTap: () {
                  customQuickAlertView(
                    context,
                    text: isEn
                        ? 'Do you want to delete your account?'
                        : 'هل تريد حذف الحساب؟',
                    title: isEn ? 'Delete Account' : 'حذف الحساب',
                    confirmBtnText: isEn ? 'Yes' : 'نعم',
                    type: QuickAlertType.warning,
                    onConfirmBtnTap: () async {
                      final accountCubit = context.read<MoreCubit>();
                      final user = await accountCubit.getCurrentUser();
                      if (!context.mounted) return;
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
      },
    );
  }
}
