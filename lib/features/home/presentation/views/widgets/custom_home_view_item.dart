import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/core/widgets/translatable_text.dart';

class CustomHomeViewItem extends StatelessWidget {
  final String imageUrl, name;

  /// When true the [name] is automatically translated to English when the app
  /// language is set to English. Use this for Arabic content (e.g. game names).
  /// For proper names (e.g. servant names) leave this false.
  final bool shouldTranslateName;

  const CustomHomeViewItem({
    super.key,
    required this.imageUrl,
    required this.name,
    this.shouldTranslateName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomCachedNetworkImageWidget(
          imageUrl: imageUrl,
          borderRadius: 16,
          height: isDeviceInPortrait(context)
              ? MediaQuery.sizeOf(context).height * 0.15
              : MediaQuery.sizeOf(context).height * 0.42,
          width: isDeviceInPortrait(context)
              ? MediaQuery.sizeOf(context).width * 0.28
              : MediaQuery.sizeOf(context).width * 0.2,
          fit: BoxFit.cover,
        ),
        verticalSpace(8),
        if (shouldTranslateName)
          TranslatableText(name, style: TextStyles.bold13)
        else
          Text(name, style: TextStyles.bold13),
      ],
    );
  }
}
