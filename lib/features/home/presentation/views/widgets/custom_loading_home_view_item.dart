import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stepforward/core/helper_functions/get_dummy_games.dart';
import 'package:stepforward/features/home/presentation/views/widgets/custom_home_view_item.dart';

class CustomLoadingHomeViewItem extends StatelessWidget {
  const CustomLoadingHomeViewItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.21,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 16,
            ),
            child: CustomHomeViewItem(
              imageUrl: getDummyGames().coverUrl,
              name: getDummyGames().name,
            ),
          ),
          itemCount: 10,
        ),
      ),
    );
  }
}
