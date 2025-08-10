import 'package:flutter/material.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_game_hashtag_item.dart';

class GameHashTagsList extends StatelessWidget {
  final List<String> tags;
  const GameHashTagsList({
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
        itemBuilder: (context, index) => CustomGameHashTagItem(
          tagName: tags[index],
        ),
        itemCount: tags.length,
      ),
    );
  }
} 