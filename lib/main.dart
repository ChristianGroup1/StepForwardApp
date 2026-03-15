import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/cubits/locale_cubit.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/on_generate_routes.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/deep_link_service.dart';
import 'package:stepforward/core/services/firebase_auth_service.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/core/services/openai_translation_service.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/firebase_options.dart';
import 'package:stepforward/generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CacheHelper.init();
  //Bloc.observer = MyBlocObserver();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
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

  runApp(BlocProvider(create: (_) => LocaleCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String getRoute() {
      final bool isLoggedIn =
          FirebaseAuthService().isLoggedIn() &&
          CacheHelper.getData(key: kSaveUserDataKey) != null;

      return isLoggedIn ? Routes.mainView : Routes.loginView;
    }

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ScreenUtilInit(
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
            theme: ThemeData(
              fontFamily: 'Cairo',
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryColor,
              ),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            onGenerateRoute: onGenerateRoutes,
            initialRoute: getRoute(),
          ),
        );
      },
    );
  }
}
