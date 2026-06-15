import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/core/widgets/translating_text.dart';

class CustomHomeViewItem extends StatelessWidget {
  final String imageUrl, name;
  final bool isNew;
  const CustomHomeViewItem({
    super.key,
    required this.imageUrl,
    required this.name,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomCachedNetworkImageWidget(
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
            ),
            if (isNew)
              PositionedDirectional(
                top: 6,
                start: 6,
                child: _NewGameBadge(isEn: context.isEn),
              ),
          ],
        ),
        verticalSpace(8),
        // TranslatingText automatically translates to English when needed,
        // using the in-memory cache so each unique name is translated only once.
        TranslatingText(
          name,
          style: TextStyles.bold13,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _NewGameBadge extends StatelessWidget {
  const _NewGameBadge({required this.isEn});

  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF19A974),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          isEn ? 'NEW' : 'جديد',
          style: TextStyles.bold13.copyWith(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
