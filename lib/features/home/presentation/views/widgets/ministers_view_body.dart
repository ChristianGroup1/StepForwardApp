import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/search_text_field.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_minister_item.dart';
import 'package:stepforward/features/home/presentation/views/widgets/tags_list.dart';

class MinistersViewBody extends StatelessWidget {
  const MinistersViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kHorizontalPadding,
        vertical: kVerticalPadding,
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SearchTextField()),
          SliverToBoxAdapter(child: verticalSpace(20)),
          SliverToBoxAdapter(
            child: TagsList(tags: ['فرق رياضية', 'مرنمين', 'متكلمين']),
          ),
          SliverToBoxAdapter(child: verticalSpace(24)),
          SliverList.builder(
            itemBuilder: (context, index) => CustomMinisterItem(),
            itemCount: 10,
          ),
        ],
      ),
    );
  }
}
