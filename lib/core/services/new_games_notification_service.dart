import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/deep_link_service.dart';
import 'package:stepforward/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NewGamesNotificationService {
  static const String newGamesTopic = 'new_games';

  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await messaging.subscribeToTopic(newGamesTopic);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessage(initialMessage);
      });
    }
  }

  static void _handleMessage(RemoteMessage message) {
    final gameId = message.data['gameId']?.toString();
    if (gameId == null || gameId.isEmpty) return;

    final navigator = DeepLinkService.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamed(Routes.gameDetailsById, arguments: gameId);
  }
}
