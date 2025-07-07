import 'package:flutter/widgets.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';

class CustomEmptyWidget extends StatelessWidget {
  final String title,subtitle;
  const CustomEmptyWidget({
    super.key, required this.title, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(Assets.assetsImagesEmptyWidget,
        height: MediaQuery.sizeOf(context).height * 0.3,
        fit: BoxFit.cover,
        ),
        verticalSpace(24),
        Text(title,style: TextStyles.bold16,),
        verticalSpace(16),
        Text(subtitle,style: TextStyles.semiBold16.copyWith(
          color:  const Color(0xff949D9E),
        ),)
      ],
    );
  }
}

