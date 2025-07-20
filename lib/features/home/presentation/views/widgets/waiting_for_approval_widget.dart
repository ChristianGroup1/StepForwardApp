import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class WaitingForApprovalWidget extends StatelessWidget {
  const WaitingForApprovalWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.assetsImagesWatingApproval,
              height: MediaQuery.sizeOf(context).height * 0.35,
              fit: BoxFit.cover,
            ),
            verticalSpace(24),
            Text(
              ' جار مراجعة بيانات الحساب والموافقة',
              style: TextStyles.bold16,
            ),
            verticalSpace(12),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'اذا شعرت ان الموافقة تأخرت يمكنك التواصل معنا بشكل مباشر',
                  style: TextStyles.semiBold16,
                  textAlign: TextAlign.center,
                ),
                horizontalSpace(20),
                 GestureDetector(
                    onTap: () async {
                      final Uri stepForwardUrl = Uri.parse(
                        'https://www.facebook.com/stepforwardteam',
                      );

                      if (await canLaunchUrl(stepForwardUrl)) {
                        await launchUrl(
                          stepForwardUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: const FaIcon(
                      FontAwesomeIcons.facebook,
                      color: AppColors.primaryColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
    );
  }
}
