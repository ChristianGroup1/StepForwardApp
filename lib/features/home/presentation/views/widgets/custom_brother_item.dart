import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stepforward/core/cubits/locale_cubit.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';
import 'package:stepforward/core/utils/app_images.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/custom_box_decoration.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:stepforward/core/widgets/custom_cached_network_image.dart';
import 'package:stepforward/core/widgets/my_divider.dart';
import 'package:stepforward/features/home/domain/models/brothers_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/app_colors.dart';

class CustomBrotherItem extends StatefulWidget {
  final BrothersModel brotherModel;
  const CustomBrotherItem({super.key, required this.brotherModel});

  @override
  State<CustomBrotherItem> createState() => _CustomBrotherItemState();
}

class _CustomBrotherItemState extends State<CustomBrotherItem> {
  String? _translatedTags;
  String? _translatedMinistries;
  String? _translatedDenomination;
  bool _isTranslating = false;
  bool _translationDone = false;

  @override
  void initState() {
    super.initState();
    // If the app is already in English when this widget builds, translate immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final locale = context.read<LocaleCubit>().state.languageCode;
        if (locale == 'en') _translateContent();
      }
    });
  }

  Future<void> _translateContent() async {
    if (_isTranslating || _translationDone) return;
    setState(() => _isTranslating = true);

    final brother = widget.brotherModel;
    final fields = await OpenAiTranslationService.translateFields({
      'tags': brother.tags.join(' - '),
      'ministries': (brother.preferredMinistries ?? []).join(' - '),
      'denomination': brother.denomination ?? '',
    });

    if (mounted) {
      setState(() {
        _translatedTags = fields['tags'];
        _translatedMinistries = fields['ministries'];
        _translatedDenomination = fields['denomination'];
        _isTranslating = false;
        _translationDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocaleCubit, Locale>(
      listener: (context, locale) {
        if (locale.languageCode == 'en') {
          _translateContent();
        } else {
          setState(() => _translationDone = false);
        }
      },
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          final isEn = locale.languageCode == 'en';
          final brother = widget.brotherModel;

          final displayTags = isEn
              ? (_translatedTags ?? brother.tags.join(' - '))
              : brother.tags.join(' - ');
          final displayMinistries = isEn
              ? (_translatedMinistries ??
                  (brother.preferredMinistries ?? []).join(' - '))
              : (brother.preferredMinistries ?? []).join(' - ');
          final displayDenomination = isEn
              ? (_translatedDenomination ?? (brother.denomination ?? ''))
              : (brother.denomination ?? '');

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
                    if (brother.coverUrl.isEmpty) {
                      showImageViewer(
                        context,
                        Image.asset(Assets.assetsImagesStepForwardLogo).image,
                        swipeDismissible: false,
                      );
                    } else {
                      showImageViewer(
                        context,
                        Image.network(brother.coverUrl).image,
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
                    imageUrl: brother.coverUrl,
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
                              brother.name,
                              style: TextStyles.bold16,
                              maxLines: 2,
                            ),
                          ),
                          if (_isTranslating)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          horizontalSpace(8),
                          IconButton(
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              final message = isEn
                                  ? '${brother.name}, Good evening. I am ${getUserData().firstName} from ${getUserData().churchName} church. I would like to arrange a meeting with you.'
                                  : '${brother.name}، مساء البركة  انا ${getUserData().firstName} من كنيسة ${getUserData().churchName} كنت عايز ارتب مع حضرتك معاد';
                              final Uri url = Uri.parse(
                                'https://wa.me/+2${brother.phoneNumber}?text=$message',
                              );
                              if (await canLaunchUrl(url)) {
                                launchUrl(url);
                              }
                            },
                            icon: const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              await FlutterPhoneDirectCaller.callNumber(
                                brother.phoneNumber,
                              );
                            },
                            icon: const FaIcon(
                              Icons.phone_outlined,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(8),
                      Text(
                        '${isEn ? 'Denomination' : 'الطايفة'}: $displayDenomination',
                        style: TextStyles.regular14.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const MyDivider(),
                      Text(
                        displayTags,
                        style: TextStyles.bold13.copyWith(color: Colors.grey),
                      ),
                      verticalSpace(8),
                      Text(
                        '${brother.churchName} - ${brother.city} - ${brother.government}',
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(8),
                      Visibility(
                        visible:
                            brother.preferredMinistries?.isNotEmpty ?? false,
                        child: Text(
                          '# $displayMinistries',
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
        },
      ),
    );
  }
}
