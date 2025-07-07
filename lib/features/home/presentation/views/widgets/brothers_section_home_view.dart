import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
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
                Text('خدام من المنيا ', style: TextStyles.bold16),
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
              height: MediaQuery.sizeOf(context).height * 0.21,
              child: BlocBuilder<BrothersCubit, BrothersState>(
                buildWhen: (previous, current) =>
                    current is GetBrothersSuccessState ||
                    current is GetBrothersLoadingState ||
                    current is GetBrothersFailureState,
                builder: (context, state) {
                  if (state is GetBrothersSuccessState) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16,
                        ),
                        child: CustomHomeViewItem(
                          imageUrl: state.brothers[index].coverUrl,
                          name: state.brothers[index].name,
                        ),
                      ),
                      itemCount: state.brothers.length,
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
