import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_animated_loading_widget.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/data/brothers_cubit/brothers_cubit.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_brother_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/tags_list.dart';

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
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SearchTextField(
            controller: cubit.searchController,
            onChanged: (value) => cubit.searchBrothers(),
          )),
          SliverToBoxAdapter(child: verticalSpace(20)),
          SliverToBoxAdapter(
            child: TagsList(
              tags: ['فريق رياضي', 'مرنم', 'متكلم'],
              onTagToggle: cubit.toggleTag,
              selectedTags: cubit.selectedTags,
            ),
          ),
          SliverToBoxAdapter(child: verticalSpace(24)),
          BlocBuilder<BrothersCubit, BrothersState>(
            buildWhen: (previous, current) =>
                current is GetBrothersSuccessState ||
                current is GetBrothersFailureState ||
                current is GetBrothersLoadingState,
            builder: (context, state) {
              if (state is GetBrothersSuccessState) {
                return SliverList.builder(
                  itemBuilder: (context, index) =>
                      CustomBrotherItem(brotherModel: state.brothers[index]),
                  itemCount: state.brothers.length,
                );
              } else if (state is GetBrothersLoadingState) {
                return const SliverToBoxAdapter(
                  child: Center(child: CustomAnimatedLoadingWidget()),
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
      ),
    );
  }
}
