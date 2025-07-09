import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/widgets/custom_show_more_blurred_item.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_home_view_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_loading_home_view_item.dart';

class BrothersSectionHomeView extends StatelessWidget {
  final VoidCallback onNavigateToBrothersView;

  const BrothersSectionHomeView({
    super.key,
    required this.onNavigateToBrothersView,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: getUserData().isApproved,
        child: Column(
          children: [
            Row(
              children: [
                Text('خدام وفرق', style: TextStyles.bold16),
                Spacer(),
                GestureDetector(
                  onTap: () => onNavigateToBrothersView(),
                  child: Text(
                    'المزيد',
                    style: TextStyles.semiBold13.copyWith(
                      color: Color(0xffA5A5A5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: isDeviceInPortrait(context)
                  ? MediaQuery.sizeOf(context).height * 0.22
                  : MediaQuery.sizeOf(context).height * 0.55,
              child: BlocBuilder<BrothersCubit, BrothersState>(
                buildWhen: (previous, current) =>
                    current is GetBrothersSuccessState ||
                    current is GetBrothersLoadingState ||
                    current is GetBrothersFailureState,
                builder: (context, state) {
                  if (state is GetBrothersSuccessState) {
                    final brothers = state.brothers.isEmpty
                        ? context.read<BrothersCubit>().allBrothers
                        : state.brothers;

                    final showMore = brothers.length > 5;
                    final itemCount = showMore ? 6 : brothers.length;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (showMore && index == 5) {
                          // Show "More" button as the 6th item
                          return GestureDetector(
                            onTap: onNavigateToBrothersView,
                            child: CustomShowMoreBlurredItem(
                              blurImageUrl: state.brothers[5].coverUrl,
                            ),
                          );
                        }

                        final brother = brothers[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 16,
                          ),
                          child: GestureDetector(
                            onTap: () => onNavigateToBrothersView(),
                            child: CustomHomeViewItem(
                              imageUrl: brother.coverUrl,
                              name: brother.name,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is GetBrothersLoadingState) {
                    return const CustomLoadingHomeViewItem();
                  } else if (state is GetBrothersFailureState) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل الخدام',
                        style: TextStyles.regular16.copyWith(color: Colors.red),
                      ),
                    );
                  } else {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
