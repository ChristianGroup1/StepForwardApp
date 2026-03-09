// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// Navigation & common labels
  String get home => Intl.message('الرئيسية', name: 'home', desc: 'Home tab');
  String get games =>
      Intl.message('الألعاب', name: 'games', desc: 'Games tab');
  String get servants =>
      Intl.message('الخدام', name: 'servants', desc: 'Servants tab');
  String get more => Intl.message('المزيد', name: 'more', desc: 'More tab');

  /// More screen actions
  String get favorites =>
      Intl.message('المفضلة', name: 'favorites', desc: 'Favorites');
  String get editProfile => Intl.message(
    'تعديل الملف الشخصي',
    name: 'editProfile',
    desc: 'Edit profile',
  );
  String get resetPassword => Intl.message(
    'اعادة تعيين كلمة المرور',
    name: 'resetPassword',
    desc: 'Reset password',
  );
  String get aboutUs =>
      Intl.message('من نحن', name: 'aboutUs', desc: 'About us');
  String get logout =>
      Intl.message('تسجيل الخروج', name: 'logout', desc: 'Logout');
  String get deleteAccount =>
      Intl.message('حذف الحساب', name: 'deleteAccount', desc: 'Delete account');

  /// Game details labels
  String get appropriateAge => Intl.message(
    'السن المناسب',
    name: 'appropriateAge',
    desc: 'Appropriate age label',
  );
  String get gameVideo => Intl.message(
    'فيديو اللعبة',
    name: 'gameVideo',
    desc: 'Game video label',
  );
  String get gameExplanation => Intl.message(
    'شرح اللعبة',
    name: 'gameExplanation',
    desc: 'Game explanation label',
  );
  String get requiredTools => Intl.message(
    'الأدوات المطلوبة',
    name: 'requiredTools',
    desc: 'Required tools label',
  );
  String get rules =>
      Intl.message('القوانين', name: 'rules', desc: 'Rules label');
  String get spiritualGoal => Intl.message(
    'الهدف الروحي',
    name: 'spiritualGoal',
    desc: 'Spiritual goal label',
  );

  /// Language settings
  String get language =>
      Intl.message('اللغة', name: 'language', desc: 'Language');
  String get arabic =>
      Intl.message('العربية', name: 'arabic', desc: 'Arabic language');
  String get english =>
      Intl.message('الإنجليزية', name: 'english', desc: 'English language');

  /// Games view
  String get allGames =>
      Intl.message('الألعاب', name: 'allGames', desc: 'All games title');
  String get noGamesForAge => Intl.message(
    'لا يوجد العاب لهذا السن',
    name: 'noGamesForAge',
    desc: 'No games message',
  );
  String get moreGamesComingSoon => Intl.message(
    'سيتم اضافة العاب اكثر قريبًا',
    name: 'moreGamesComingSoon',
    desc: 'More games coming soon',
  );
  String get addedToFavorites => Intl.message(
    'تم اضافة اللعبة للمفضلة',
    name: 'addedToFavorites',
    desc: 'Added to favorites',
  );
  String get removedFromFavorites => Intl.message(
    'تم حذف اللعبة من المفضلة',
    name: 'removedFromFavorites',
    desc: 'Removed from favorites',
  );

  /// Dialogs
  String get logoutConfirmTitle => Intl.message(
    'تسجيل الخروج',
    name: 'logoutConfirmTitle',
    desc: 'Logout confirm title',
  );
  String get logoutConfirmText => Intl.message(
    'هل تريد تسجيل الخروج؟',
    name: 'logoutConfirmText',
    desc: 'Logout confirm text',
  );
  String get yes => Intl.message('نعم', name: 'yes', desc: 'Yes button');
  String get deleteAccountTitle => Intl.message(
    'حذف الحساب',
    name: 'deleteAccountTitle',
    desc: 'Delete account title',
  );
  String get deleteAccountText => Intl.message(
    'هل تريد حذف الحساب؟',
    name: 'deleteAccountText',
    desc: 'Delete account text',
  );

  /// Translation status
  String get translating =>
      Intl.message('جاري الترجمة...', name: 'translating', desc: 'Translating');
  String get translationFailed => Intl.message(
    'فشل في الترجمة',
    name: 'translationFailed',
    desc: 'Translation failed',
  );

  /// Age tags
  String get childrenTag =>
      Intl.message('اطفال', name: 'childrenTag', desc: 'Children tag');
  String get preparatoryTag =>
      Intl.message('اعدادي', name: 'preparatoryTag', desc: 'Preparatory tag');
  String get secondaryTag =>
      Intl.message('ثانوي', name: 'secondaryTag', desc: 'Secondary tag');
  String get universityTag =>
      Intl.message('جامعة', name: 'universityTag', desc: 'University tag');

  /// Search
  String get searchHint =>
      Intl.message('بحث...', name: 'searchHint', desc: 'Search hint');

  /// Servants / Brothers
  String get allServants =>
      Intl.message('الخدام', name: 'allServants', desc: 'All servants title');
  String get noGamesFound => Intl.message(
    'لا يوجد نتائج',
    name: 'noGamesFound',
    desc: 'No results found',
  );

  /// Home sections
  String get gamesSection =>
      Intl.message('ألعاب', name: 'gamesSection', desc: 'Games section title');
  String get servantsAndTeams => Intl.message(
    'خدام وفرق',
    name: 'servantsAndTeams',
    desc: 'Servants and teams section title',
  );
  String get seeMore =>
      Intl.message('المزيد', name: 'seeMore', desc: 'See more button');
  String get brothersLoadError => Intl.message(
    'حدث خطأ أثناء تحميل الخدام',
    name: 'brothersLoadError',
    desc: 'Error loading servants',
  );
  String get welcomeUser =>
      Intl.message('اهلًا بك', name: 'welcomeUser', desc: 'Welcome greeting');
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

