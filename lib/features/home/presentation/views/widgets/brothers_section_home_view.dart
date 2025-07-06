import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
class BrothersSectionHomeView extends StatelessWidget {
  const BrothersSectionHomeView({
    super.key,
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
                Text('خدام محافظة المنيا ', style: TextStyles.bold16),
                Spacer(),
                Text(
                  'المزيد',
                  style: TextStyles.semiBold13.copyWith(
                    color: Color(0xffA5A5A5),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.2,
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
                        child: Column(
                          children: [
                            CustomCachedNetworkImageWidget(
                              imageUrl: state.brothers[index].coverUrl,
                              borderRadius: 16,
                              height:
                                  MediaQuery.sizeOf(context).height *
                                  0.14,
                              fit: BoxFit.fill,
                              width:
                                  MediaQuery.sizeOf(context).width * 0.2,
                            ),
                            verticalSpace(8),
                            Text(
                              state.brothers[index].name,
                              style: TextStyles.bold13,
                            ),
                          ],
                        ),
                      ),
                      itemCount: state.brothers.length,
                    );
                  } else if (state is GetBrothersLoadingState) {
                    return const Center(
                      child: CustomAnimatedLoadingWidget(),
                    );
                  } else if (state is GetBrothersFailureState) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل الخدام',
                        style: TextStyles.regular16.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else {
                    return const SliverToBoxAdapter(
                      child: SizedBox.shrink(),
                    );
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

