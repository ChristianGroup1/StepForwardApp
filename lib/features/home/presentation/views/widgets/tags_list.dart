import 'package:flutter/material.dart';
import 'custom_tag_item.dart';

class TagsList extends StatelessWidget {
  final List<String> tags;
  final List<String> selectedTags;
  final void Function(String tag) onTagToggle;
  final ScrollPhysics? physics;

  const TagsList({
    super.key,
    required this.tags,
    this.physics,
    required this.selectedTags,
    required this.onTagToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:physics?? const BouncingScrollPhysics(),
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedTags.contains(tag);

          return CustomTagItem(
            tagName: tag,
            isSelected: isSelected,
            onTap: () => onTagToggle(tag),
          );
        },
      ),
    );
  }
}
