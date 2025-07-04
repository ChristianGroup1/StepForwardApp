import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:stepforward/core/helper_functions/custom_quick_alret_view.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_more_list_tile_item.dart';

class CustomMoreViewListTileActions extends StatelessWidget {
  const CustomMoreViewListTileActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomMoreViewListTileItem(
            title: Text(
              'تعديل الملف الشخصي',
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
          const Divider(),
          CustomMoreViewListTileItem(
            title: Text(
              'تغيير كلمة المرور',
              style: TextStyles.bold16,
            ),
            leading: const Icon(
              Icons.lock,
              color: AppColors.primaryColor,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryColor,
            ),
            onTap: () => context.pushNamed(Routes.mainView),
          ),
          const Divider(),
          CustomMoreViewListTileItem(
            title: Text(
              'المفضلة',
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
            onTap: () {
              context.pushNamed(Routes.favoritesView);
            },
          ),
          
          const Divider(),
         
          CustomMoreViewListTileItem(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('تسجيل الخروج',
                style: TextStyles.bold16.copyWith(color: Colors.red)),
            onTap: () {
              customQuickAlertView(
                context,
                text: 'هل تريد تسجيل الخروج؟',
                title: 'تسجيل الخروج',
                confirmBtnText: 'نعم',
                
                type: QuickAlertType.warning,
                onConfirmBtnTap: () async {
                  //await context.read<MoreCubit>().logOut();
                  context.pushReplacementNamed(Routes.loginView);
                },
              );
            },
          ),
          const Divider(),

          // Delete Account
          CustomMoreViewListTileItem(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text('حذف الحساب',
                style: TextStyles.bold16.copyWith(color: Colors.red)),
            onTap: () {
              customQuickAlertView(
                context,
                text: 'هل تريد حذف الحساب؟',
                title: 'حذف الحساب',
                confirmBtnText: 'نعم',
                
                type: QuickAlertType.warning,
                onConfirmBtnTap: () async {
                 // await context.read<MoreCubit>().logOut();
                  context.pushReplacementNamed(Routes.loginView);
                },
              );
            },
          ),
          verticalSpace(24.h)
        ],
      ),
    );
  }
}