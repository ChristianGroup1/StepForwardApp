import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/cubits/locale_cubit.dart';
import 'package:stepforward/core/cubits/theme_cubit.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/helper_functions/on_generate_routes.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/deep_link_service.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/core/services/new_games_notification_service.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_theme.dart';
import 'package:stepforward/firebase_options.dart';
import 'package:stepforward/generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await CacheHelper.init();
  //Bloc.observer = MyBlocObserver();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  setupGetIt();

  // Translation is powered by the free MyMemory API — no API key required.
  // Optionally pass a registered MyMemory e-mail to increase the daily limit:
  //   flutter run --dart-define=TRANSLATION_EMAIL=your@email.com
  OpenAiTranslationService.configure(
    email: const String.fromEnvironment(
      'TRANSLATION_EMAIL',
      defaultValue: 'fadykhayrat@gmail.com',
    ),
  );

  // Initialise deep-link handling (stepforward://game/{id}).
  await DeepLinkService.init();
  await NewGamesNotificationService.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String getRoute() {
      return hasCachedUserData() ? Routes.mainView : Routes.loginView;
    }

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final platformBrightness = MediaQuery.platformBrightnessOf(context);
            final isDark =
                themeMode == ThemeMode.dark ||
                (themeMode == ThemeMode.system &&
                    platformBrightness == Brightness.dark);
            const statusBarColor = AppColors.primaryColor;
            final navigationBarColor = isDark
                ? AppTheme.dark.scaffoldBackgroundColor
                : AppTheme.light.scaffoldBackgroundColor;
            final overlayStyle = SystemUiOverlayStyle(
              statusBarColor: statusBarColor,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: navigationBarColor,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarDividerColor: navigationBarColor,
            );

            SystemChrome.setSystemUIOverlayStyle(overlayStyle);

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: ScreenUtilInit(
                designSize: const Size(360, 800),
                minTextAdapt: false,
                child: MaterialApp(
                  // Global navigator key used by DeepLinkService for deep links.
                  navigatorKey: DeepLinkService.navigatorKey,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1)),
                      child: child!,
                    );
                  },
                  title: 'Step Forward',
                  localizationsDelegates: [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  locale: locale,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  debugShowCheckedModeBanner: false,
                  onGenerateRoute: onGenerateRoutes,
                  initialRoute: getRoute(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
