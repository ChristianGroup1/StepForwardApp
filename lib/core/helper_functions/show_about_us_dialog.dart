import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

void showAboutUsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('من نحن', style: TextStyles.bold23),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle('✨ فكرتنا'),
              buildSectionContent(
                'إحنا مجموعة من الخدام المسيحيين من مختلف الكنائس اجتمعنا على فكرة بسيطة وعملنا تطبيق يساعد كل خادم في أي خدمة (مدارس الأحد، إعدادي، ثانوي، جامعة) يلاقي الألعاب الروحية المناسبة ويقدّم رسالة المسيح بطريقة ممتعة وقوية.',
              ),
              buildSectionTitle('🎯 هدفنا'),
              buildSectionContent(
                'نوصل الكلمة والهدف الروحي من خلال لعبة ممتعة ومؤثرة بتوصل التعليم من غير ما تُنسى. التطبيق بيساعدك تلاقي اللعبة المناسبة للموضوع اللي بتخدم عنه سواء في اجتماع أو يوم رياضي.',
              ),
              buildSectionTitle('🧠 المميزات'),
              buildSectionContent(
                '🔹 مكتبة كبيرة من الألعاب الروحية\n🔹 إمكانيّة البحث حسب الموضوع أو الفئة\n🔹 خدام ومرنمين وفِرَق خدمة من كل المحافظات\n🔹 مساعد ذكي (ChatBot) يساعدك تحضّر اجتماعك بسهولة',
              ),
              buildSectionTitle('🤖 الـ ChatBot'),
              buildSectionContent(
                'أضفنا مساعد ذكي داخل التطبيق! تقدر تسأله عن ألعاب تناسب الموضوع اللي بتتكلم فيه، وهيقترح عليك أفكار جاهزة تقدر تنفذها فورًا.',
              ),
              buildSectionTitle('📣 خدام من كل مصر'),
              buildSectionContent(
                'دلوقتي تقدر تشوف خدام متكلمين، مرنمين، وفِرَق خدمة من كل محافظة في مصر، وتتعرف على مواهب جديدة تقدر تخدم بيها معاك.',
              ),
              buildSectionTitle('📬 تواصل معنا'),

              buildSectionContent(
                'لأي استفسارات أو تعديلات متعلقة بالتطبيق، يمكنك التواصل على صفحة الفريق او مباشرة مع المطور :',
              ),

               Row(
                 children: [
                   buildSectionTitle(
                   'صفحة الفريق : ',
                               
                                 ),
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
                    child: FaIcon(
                      FontAwesomeIcons.facebook,
                      color: AppColors.primaryColor,
                    ),
                  ),
                 ],
               ),
              

              SizedBox(height: 8),
              Row(
                children: [
                   buildSectionTitle('مطور التطبيق : '),
                   horizontalSpace(4),
                  GestureDetector(
                    onTap: () async {
                      final Uri gitHubUrl = Uri.parse(
                        'https://github.com/JohnAmir450',
                      );

                      if (await canLaunchUrl(gitHubUrl)) {
                        await launchUrl(
                          gitHubUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: FaIcon(
                      FontAwesomeIcons.github,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final Uri linkedInUri = Uri.parse(
                        'https://www.linkedin.com/in/john-amir-135587240/',
                      );

                      if (await canLaunchUrl(linkedInUri)) {
                        await launchUrl(
                          linkedInUri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: FaIcon(
                      FontAwesomeIcons.linkedin,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final Uri whatsappUri = Uri.parse(
                        'https://wa.me/201288140684',
                      );
                      if (await canLaunchUrl(whatsappUri)) {
                        await launchUrl(
                          whatsappUri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'إغلاق',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ),
        ],
      );
    },
  );
}

// 🛠 Helper widgets
Widget buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
    child: Text(
      title,
      style: TextStyles.bold16.copyWith(color: AppColors.primaryColor),
    ),
  );
}

Widget buildSectionContent(
  String content, {
  String? linkText,
  String? linkUrl,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: linkText != null && linkUrl != null
        ? RichText(
            text: TextSpan(
              text: content,
              style: TextStyles.semiBold13.copyWith(color: Colors.black),
              children: [
                TextSpan(
                  text: ' $linkText',
                  style: TextStyles.semiBold13.copyWith(
                    color: AppColors.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final uri = Uri.parse(linkUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                ),
              ],
            ),
          )
        : Text(
            content,
            style: TextStyles.semiBold13,
            textAlign: TextAlign.justify,
          ),
  );
}
