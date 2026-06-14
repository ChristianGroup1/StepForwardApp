import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stepforward/core/utils/app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => _theme(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  );

  static ThemeData get dark => _theme(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff101317),
    surface: const Color(0xff171B21),
    onSurface: const Color(0xffF4F6F8),
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color surface,
    required Color onSurface,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: brightness,
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      fontFamily: 'Cairo',
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: scaffoldBackgroundColor,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.grey.shade300,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? const Color(0xff1E242C)
            : const Color(0xffF9FAFA),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primaryColor,
        textColor: onSurface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryColor;
          }
          return null;
        }),
      ),
    );
  }
}
