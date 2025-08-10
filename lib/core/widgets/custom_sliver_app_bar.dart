import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_details_view_body.dart';

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({
    super.key,
    required this.widget,
  });

  final GameDetailsViewBody widget;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      collapsedHeight: 70,
      expandedHeight:isDeviceInPortrait(context)? MediaQuery.of(context).size.height * 0.35:  MediaQuery.of(context).size.height * 0.6,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed =
              constraints.maxHeight <120;
    
          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding:  EdgeInsets.symmetric(
              horizontal: isDeviceInPortrait(context) ?  40: 90,
              vertical:isDeviceInPortrait(context) ? 24: 18,
            ),
            title: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                if (isCollapsed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CustomCachedNetworkImageWidget(
                      borderRadius: 16,
                      imageUrl: widget.game.coverUrl,
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (isCollapsed) const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.game.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.bold16.copyWith(
                      fontSize: isCollapsed ? 16 : 20,
                      color: isCollapsed
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Blurred background image
                CustomCachedNetworkImageWidget(
                  imageUrl: widget.game.coverUrl,
                  fit: BoxFit.cover,
                  borderRadius: 16,
                ),
                // Blur effect
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: const SizedBox(),
                  ),
                ),
                // Centered image (Avatar style)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: kToolbarHeight),
                    CustomCachedNetworkImageWidget(
                      imageUrl: widget.game.coverUrl,
                      height:
                          MediaQuery.of(context).size.height * 0.2,
    
                      borderRadius: 16,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}