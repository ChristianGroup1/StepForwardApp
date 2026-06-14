import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_loadSavedThemeMode());

  static ThemeMode _loadSavedThemeMode() {
    final saved = CacheHelper.getData(key: kAppThemeModeKey) as String?;
    return saved == ThemeMode.dark.name ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    await CacheHelper.saveData(key: kAppThemeModeKey, value: themeMode.name);
    emit(themeMode);
  }

  Future<void> toggleTheme(bool isDark) {
    return changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDark => state == ThemeMode.dark;
}
