import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/features/home/data/home_cubit/home_cubit.dart';

import 'custom_tag_item.dart';

class TagsList extends StatelessWidget {
  final List<String> tags;

  const TagsList({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    final selectedTags = context.watch<HomeCubit>().selectedTags;

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedTags.contains(tag);
          return CustomTagItem(
            tagName: tag,
            isSelected: isSelected,
            onTap: () => context.read<HomeCubit>().toggleTag(tag),
          );
        },
      ),
    );
  }
}


