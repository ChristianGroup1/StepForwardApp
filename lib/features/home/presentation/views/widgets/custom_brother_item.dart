import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/utils/app_images.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      padding: const EdgeInsets.all(8.0),
      decoration: customCardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (brotherModel.coverUrl.isEmpty) {
                showImageViewer(
                  context,
                  Image.asset(Assets.assetsImagesStepForwardLogo).image,
                  swipeDismissible: false,
                );
              } else {
                showImageViewer(
                  context,
                  Image.network(brotherModel.coverUrl).image,
                  useSafeArea: true,
                  doubleTapZoomable: true,
                  swipeDismissible: false,
                );
              }
            },
            child: CustomCachedNetworkImageWidget(
              height: isDeviceInPortrait(context)
                  ? MediaQuery.sizeOf(context).height * 0.16
                  : MediaQuery.sizeOf(context).height * 0.5,
              width: MediaQuery.sizeOf(context).width * 0.25,
              fit: BoxFit.cover,
              imageUrl: brotherModel.coverUrl,
              borderRadius: 16,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        brotherModel.name,
                        style: TextStyles.bold16,
                        maxLines: 2,
                      ),
                    ),
                    horizontalSpace(24),
                    GestureDetector(
                      onTap: () async {
                        final message =
                            '${brotherModel.name}، مساء البركة  انا ${getUserData().firstName} من كنيسة ${getUserData().churchName} كنت عايز ارتب مع حضرتك معاد';
                        final Uri url = Uri.parse(
                          'https://wa.me/+2${brotherModel.phoneNumber}?text=$message',
                        );
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        }
                      },
                      child: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    horizontalSpace(12),
                    GestureDetector(
                      onTap: () async {
                        await FlutterPhoneDirectCaller.callNumber(
                          brotherModel.phoneNumber,
                        );
                      },
                      child: const FaIcon(
                        Icons.phone_outlined,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                verticalSpace(8),
                Text(
                  'الطايفة: ${brotherModel.denomination}',
                  style: TextStyles.regular14.copyWith(color: Colors.grey),
                ),
                const MyDivider(),
                Text(
                  brotherModel.tags.join(' - '),
                  style: TextStyles.bold13.copyWith(color: Colors.grey),
                ),
                verticalSpace(8),
                Text(
                  '${brotherModel.churchName} - ${brotherModel.city} -  ${brotherModel.government}',
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace(8),
                Visibility(
                  visible:
                      brotherModel.preferredMinistries?.isNotEmpty ?? false,
                  child: Text(
                    '# ${brotherModel.preferredMinistries?.join(' - ')}',
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
