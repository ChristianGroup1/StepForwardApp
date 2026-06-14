import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stepforward/core/cubits/theme_cubit.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';

void main() {
  test('ThemeCubit saves and restores dark mode', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    final cubit = ThemeCubit();
    expect(cubit.state, ThemeMode.light);

    await cubit.toggleTheme(true);
    expect(cubit.state, ThemeMode.dark);
    await cubit.close();

    final restoredCubit = ThemeCubit();
    expect(restoredCubit.state, ThemeMode.dark);
    await restoredCubit.close();
  });
}
