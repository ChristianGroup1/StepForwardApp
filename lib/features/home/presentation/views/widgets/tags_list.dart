import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/spacing.dart';

import 'custom_tag_item.dart';

class TagsList extends StatelessWidget {
  final List<String> tags;
  const TagsList({
    super.key, required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity ,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) => horizontalSpace(12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => CustomTagItem(
          tagName: tags[index],
        ),
        itemCount: tags.length,
      ),
    );
  }
}

