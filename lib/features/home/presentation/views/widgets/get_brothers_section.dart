import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stepforward/core/helper_functions/custom_government_modal_sheet_filter.dart';
import 'package:stepforward/core/helper_functions/get_dummy_brother.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_demonition_item.dart';
import 'package:stepforward/core/widgets/custom_empty_widget.dart';
import 'package:stepforward/core/widgets/custom_government_item.dart';
import 'package:stepforward/core/widgets/custom_page_app_bar.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_brother_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_tag_item.dart';
import 'package:stepforward/generated/l10n.dart';

class GetBrothersSection extends StatelessWidget {
  const GetBrothersSection({
    super.key,
    required this.cubit,
  });

  final BrothersCubit cubit;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: CustomPageAppBar(title: s.allServants),
          ),
          SliverToBoxAdapter(child: verticalSpace(24)),
          SliverToBoxAdapter(
            child: SearchTextField(
              controller: cubit.searchController,
              onChanged: (value) {
                if (value.isEmpty) {
                  cubit.getBrothers();
                } else {
                  cubit.searchBrothers();
                }
              },
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
                      customGovernmentFilterModalSheet(
                        context,
                        cubit,
                      );
                    },
                  ),
                  horizontalSpace(12),
                  CustomDenominationItem(
                    denomination: cubit.selectedDenomination,
                    onTap: () {
                      customBrotherFilterModalSheet(context, cubit);
                    },
                  ),
                  horizontalSpace(12),
                  ...[
                    'مرنم',
                    'متكلم',
                    'فريق رياضي',
                    'فريق تمثيل',
                    'فريق ترانيم',
                  ].map((tag) {
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
                      title: s.noGamesFound,
                      subtitle: '',
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
                      physics: const NeverScrollableScrollPhysics(),
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
                      style: const TextStyle(color: Colors.red),
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
        ],
      );
  }
}
