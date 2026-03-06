import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class WaitingForApprovalWidget extends StatelessWidget {
  const WaitingForApprovalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Image.asset(
            Assets.assetsImagesWatingApproval,
            height: MediaQuery.sizeOf(context).height * 0.35,
            fit: BoxFit.cover,
          ),
          verticalSpace(12),
          Text(
            'تم إستلام البطاقة وجاري مراجعة البيانات والموافقة',
            style: TextStyles.bold16,
            textAlign: TextAlign.center,
          ),
          verticalSpace(12),
          const Text(
            'اذا شعرت ان الموافقة تأخرت يمكنك التواصل معنا بشكل مباشر',
            style: TextStyles.semiBold16,
            textAlign: TextAlign.center,
          ),
          verticalSpace(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final Uri stepForwardUrl = Uri.parse(
                    'https://www.facebook.com/ElShaddaiSportTeam',
                  );
    
                  if (await canLaunchUrl(stepForwardUrl)) {
                    await launchUrl(
                      stepForwardUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                icon: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: AppColors.primaryColor,
                ),
              ),
              
              IconButton(
                
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final Uri teamWhatsappUrl = Uri.parse(
                    'https://wa.me/+201224999086',
                  );
    
                  if (await canLaunchUrl(teamWhatsappUrl)) {
                    await launchUrl(
                      teamWhatsappUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
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
