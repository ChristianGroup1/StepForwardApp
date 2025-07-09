import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';

class CustomHomeViewItem extends StatelessWidget {
  final String imageUrl,name;
  const CustomHomeViewItem({
    super.key, required this.imageUrl, required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomCachedNetworkImageWidget(
          imageUrl: imageUrl,
          borderRadius: 16,
          height:isDeviceInPortrait(context)? MediaQuery.sizeOf(context).height * 0.15:  MediaQuery.sizeOf(context).height * 0.42,
          width: isDeviceInPortrait(context)?
                MediaQuery.sizeOf(context).width * 0.26:  MediaQuery.sizeOf(context).width * 0.2,
          fit: BoxFit.cover,
        ),
        verticalSpace(8),
        Text(
         name,
          style: TextStyles.bold13,
        ),
      ],
    );
  }
}
