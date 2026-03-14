import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

void showAboutUsDialog(BuildContext context) {
  final isEn = context.isEn;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(isEn ? 'About Us' : 'من نحن', style: TextStyles.bold23),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: isEn ? _buildEnglishContent() : _buildArabicContent(),
          ),
        ),
        actions: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isEn ? 'Close' : 'إغلاق',
                style: const TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ),
        ],
      );
    },
  );
}

List<Widget> _buildArabicContent() => [
  _sectionTitle('✨ فكرتنا'),
  _sectionContent(
    'إحنا مجموعة من الخدام المسيحيين من مختلف الكنائس اجتمعنا على فكرة بسيطة وعملنا تطبيق يساعد كل خادم في أي خدمة (مدارس الأحد، إعدادي، ثانوي، جامعة) يلاقي الألعاب الروحية المناسبة ويقدّم رسالة المسيح بطريقة ممتعة وقوية.',
  ),
  _sectionTitle('🎯 هدفنا'),
  _sectionContent(
    'نوصل الكلمة والهدف الروحي من خلال لعبة ممتعة ومؤثرة بتوصل التعليم من غير ما تُنسى. التطبيق بيساعدك تلاقي اللعبة المناسبة للموضوع اللي بتخدم عنه سواء في اجتماع أو يوم رياضي.',
  ),
  _sectionTitle('🧠 المميزات'),
  _sectionContent(
    '🔹 مكتبة كبيرة من الألعاب الروحية\n🔹 إمكانيّة البحث حسب الموضوع أو الفئة\n🔹 خدام ومرنمين وفِرَق خدمة من كل المحافظات\n🔹 مساعد ذكي (ChatBot) يساعدك تحضّر اجتماعك بسهولة',
  ),
  _sectionTitle('🤖 الـ ChatBot'),
  _sectionContent(
    'أضفنا مساعد ذكي داخل التطبيق! تقدر تسأله عن ألعاب تناسب الموضوع اللي بتتكلم فيه، وهيقترح عليك أفكار جاهزة تقدر تنفذها فورًا.',
  ),
  _sectionTitle('📣 خدام من كل مصر'),
  _sectionContent(
    'دلوقتي تقدر تشوف خدام متكلمين، مرنمين، وفِرَق خدمة من كل محافظة في مصر، وتتعرف على مواهب جديدة تقدر تخدم بيها معاك.',
  ),
  _sectionTitle('📬 تواصل معنا'),
  _sectionContent(
    'لأي استفسارات أو تعديلات متعلقة بالتطبيق، يمكنك التواصل على صفحة الفريق او مباشرة مع المطور :',
  ),
  _contactRow(),
];

List<Widget> _buildEnglishContent() => [
  _sectionTitle('✨ Our Idea'),
  _sectionContent(
    'We are a group of Christian servants from different churches who came together around a simple idea and built an app to help every servant in any ministry (Sunday school, middle school, high school, university) find the right spiritual games and present the message of Christ in a fun and powerful way.',
  ),
  _sectionTitle('🎯 Our Goal'),
  _sectionContent(
    'Deliver the Word and spiritual goal through a fun and impactful game that makes lessons unforgettable. The app helps you find the right game for the topic you are serving — whether in a meeting or a sports day.',
  ),
  _sectionTitle('🧠 Features'),
  _sectionContent(
    '🔹 Large library of spiritual games\n🔹 Search by topic or age group\n🔹 Servants, singers, and ministry teams from all governorates\n🔹 Smart assistant (ChatBot) to help you prepare your meeting easily',
  ),
  _sectionTitle('🤖 The ChatBot'),
  _sectionContent(
    'We added a smart assistant inside the app! You can ask it for games that suit your topic, and it will suggest ready-made ideas you can implement right away.',
  ),
  _sectionTitle('📣 Servants from All Over Egypt'),
  _sectionContent(
    'Now you can see speakers, singers, and ministry teams from every governorate in Egypt and discover new talents you can serve with.',
  ),
  _sectionTitle('📬 Contact Us'),
  _sectionContent(
    'For any inquiries or suggestions about the app, you can reach us through the team page or directly with the developer:',
  ),
  _contactRow(),
];

Widget _contactRow() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        _sectionTitle('Team page: '),
        IconButton(
          constraints: const BoxConstraints(),
          onPressed: () async {
            final Uri url = Uri.parse('https://www.facebook.com/ElShaddaiSportTeam');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const FaIcon(FontAwesomeIcons.facebook, color: AppColors.primaryColor),
        ),
        IconButton(
          constraints: const BoxConstraints(),
          onPressed: () async {
            final Uri url = Uri.parse('https://wa.me/+201224999086');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.primaryColor),
        ),
      ],
    ),
    const SizedBox(height: 8),
    Row(
      children: [
        _sectionTitle('App developer: '),
        horizontalSpace(4),
        IconButton(
          constraints: const BoxConstraints(),
          onPressed: () async {
            final Uri url = Uri.parse('https://github.com/JohnAmir450');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const FaIcon(FontAwesomeIcons.github, color: AppColors.primaryColor),
        ),
        IconButton(
          constraints: const BoxConstraints(),
          onPressed: () async {
            final Uri url = Uri.parse('https://www.linkedin.com/in/john-amir-135587240/');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const FaIcon(FontAwesomeIcons.linkedin, color: AppColors.primaryColor),
        ),
        IconButton(
          constraints: const BoxConstraints(),
          onPressed: () async {
            final Uri url = Uri.parse('https://www.facebook.com/john.amir.1804');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const FaIcon(FontAwesomeIcons.facebook, color: AppColors.primaryColor),
        ),
      ],
    ),
  ],
);

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
    child: Text(
      title,
      style: TextStyles.bold16.copyWith(color: AppColors.primaryColor),
    ),
  );
}

Widget _sectionContent(String content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(content, style: TextStyles.semiBold13, textAlign: TextAlign.justify),
  );
}
