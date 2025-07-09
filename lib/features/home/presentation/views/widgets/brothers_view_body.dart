import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stepforward/core/helper_functions/custom_government_modal_sheet_filter.dart';
import 'package:stepforward/core/helper_functions/get_dummy_brother.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/core/widgets/custom_government_item.dart';
import 'package:stepforward/core/widgets/custom_page_app_bar.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_brother_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_tag_item.dart';

class BrothersViewBody extends StatelessWidget {
  const BrothersViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<BrothersCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding,
        vertical: kVerticalPadding,
      ),
      child: getUserData().isApproved
          ? CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: CustomPageAppBar(title: 'الخدام')),
                SliverToBoxAdapter(child: verticalSpace(24)),
                SliverToBoxAdapter(
                  child: SearchTextField(
                    controller: cubit.searchController,
                    onChanged: (value) => cubit.searchBrothers(),
                  ),
                ),
                SliverToBoxAdapter(child: verticalSpace(24)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                       
                        CustomGovernorateTagItem(
                          governorate: cubit.selectedGovernment,
                          onTap: () {
                            customGovernmentFilterModalSheet(context, cubit);
                          },
                        ),
                        horizontalSpace(12),
                        ...['فريق رياضي', 'مرنم', 'متكلم'].map((tag) {
                          final isSelected = cubit.selectedTags.contains(tag);
                          return Row(
                            children: [
                              CustomTagItem(
                                tagName: tag,
                                isSelected: isSelected,
                                onTap: () => cubit.toggleTag(tag),
                              ),
                              horizontalSpace(12),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: verticalSpace(24)),

                SliverToBoxAdapter(child: verticalSpace(24)),
                BlocBuilder<BrothersCubit, BrothersState>(
                  buildWhen: (previous, current) =>
                      current is GetBrothersSuccessState ||
                      current is GetBrothersFailureState ||
                      current is GetBrothersLoadingState,
                  builder: (context, state) {
                    if (state is GetBrothersSuccessState) {
                      if (state.brothers.isEmpty) {
                        return SliverToBoxAdapter(
                          child: CustomEmptyWidget(
                            title: 'لم يتم ايجاد خدام',
                            subtitle: 'سيتم اضافة خدام في أقرب وقت',
                          ),
                        );
                      }
                      return SliverList.builder(
                        itemBuilder: (context, index) => CustomBrotherItem(
                          brotherModel: state.brothers[index],
                        ),
                        itemCount: state.brothers.length,
                      );
                    } else if (state is GetBrothersLoadingState) {
                      return SliverToBoxAdapter(
                        child: Skeletonizer(
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 10,
                            itemBuilder: (context, index) => CustomBrotherItem(
                              brotherModel: getDummyBrother(),
                            ),
                          ),
                        ),
                      );
                    } else if (state is GetBrothersFailureState) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            state.errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                  },
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.assetsImagesWatingApproval,
                  height: MediaQuery.sizeOf(context).height * 0.35,
                  fit: BoxFit.cover,
                ),
                verticalSpace(32),
                Text(
                  ' جار مراجعة بيانات الحساب والموافقة',
                  style: TextStyles.bold16,
                ),
                verticalSpace(12),
                Text(
                  'اذا شعرت ان الموافقة تأخرت يمكنك التواصل معنا بشكل مباشر',
                  style: TextStyles.semiBold16,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}
