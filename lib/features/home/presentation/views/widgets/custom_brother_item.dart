import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_box_decoration.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/domain/models/brothers_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/utils/app_colors.dart';

class CustomBrotherItem extends StatelessWidget {
  final BrothersModel brotherModel;
  const CustomBrotherItem({super.key, required this.brotherModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0,),
      padding: const EdgeInsets.all(8.0),
      decoration: customCardDecoration(),
      child: Row(
        children: [
          CustomCachedNetworkImageWidget(
            height: MediaQuery.sizeOf(context).height * 0.2,
            width: MediaQuery.sizeOf(context).width * 0.25,
            fit: BoxFit.fill,
            imageUrl: brotherModel.coverUrl,
            borderRadius: 16,
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(brotherModel.name, style: TextStyles.bold16),
                    Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final message='مرحبا ${brotherModel.name}، كيف حالك؟';
                        final Uri url = Uri.parse('https://wa.me/+2${brotherModel.phoneNumber}?text=$message');
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        }
                      },
                      child: Icon(Icons.message_outlined, color: AppColors.primaryColor)),
                    horizontalSpace(8),
                    GestureDetector(
                      onTap: () async {
                       
                        await FlutterPhoneDirectCaller.callNumber(brotherModel.phoneNumber);
                      },
                      child: Icon(Icons.phone_outlined, color: AppColors.primaryColor)),
                  ],
                ),
                MyDivider(),
                Text(
                  brotherModel.tags.join(' - '),
                  style: TextStyles.bold13.copyWith(color: Colors.grey),
                ),
                verticalSpace(8),
                Text(
                  '${brotherModel.churchName} - ${brotherModel.government}',
                  style: TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace(8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
