import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_loadSavedLocale());

  static Locale _loadSavedLocale() {
    final saved = CacheHelper.getData(key: kAppLanguageKey) as String?;
    return Locale(saved ?? 'ar');
  }

  Future<void> changeLocale(String languageCode) async {
    await CacheHelper.saveData(key: kAppLanguageKey, value: languageCode);
    emit(Locale(languageCode));
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';
}
