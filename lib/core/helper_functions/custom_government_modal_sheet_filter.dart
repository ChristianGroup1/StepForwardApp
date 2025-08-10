import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/governments_list.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';

Future<dynamic> customGovernmentFilterModalSheet(
  BuildContext context,
  BrothersCubit cubit,
) {
  return showModalBottomSheet(
    showDragHandle: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      // Add "الكل" at the beginning
      final List<String> allGovernments = ['الكل', ...governments];

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("اختر المحافظة", style: TextStyles.bold16),
          const MyDivider(height: 32),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allGovernments.length,
              separatorBuilder: (_, __) => const MyDivider(height: 20),
              itemBuilder: (context, index) {
                final government = allGovernments[index];
                final isSelected =
                    government == cubit.selectedGovernment ||
                    (government == 'الكل' &&
                        cubit.selectedGovernment == 'الكل');

                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    government,
                    style: TextStyles.semiBold16.copyWith(
                      fontSize: isSelected ? 17 : 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : Colors.black,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primaryColor,
                        )
                      : null,
                  onTap: () {
                    cubit.changeGovernment(
                      government == 'الكل' ? 'الكل' : government,
                    );
                    context.pop();
                  },
                );
              },
            ),
          ),
          verticalSpace(14),
        ],
      );
    },
  );
}
