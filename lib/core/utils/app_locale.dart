/// Lightweight global locale flag updated by [LocaleCubit].
///
/// Use [AppLocale.isEn] in code that has no [BuildContext] (e.g., services,
/// repositories) to obtain the current language preference.
class AppLocale {
  AppLocale._();

  static bool _isEn = false;

  /// `true` when the app is currently in English.
  static bool get isEn => _isEn;

  /// Called by [LocaleCubit] whenever the locale changes.
  static void update(String languageCode) {
    _isEn = languageCode == 'en';
  }
}
