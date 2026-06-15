import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/deep_link_service.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NewGamesNotificationService {
  static const String newGamesTopic = 'new_games';
  static bool _authListenerStarted = false;

  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await messaging.subscribeToTopic(newGamesTopic);
    await saveCurrentUserToken();
    _listenToTokenChanges();
    _listenToAuthChanges();

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessage(initialMessage);
      });
    }
  }

  static Future<void> saveCurrentUserToken() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return;

    await saveTokenForUser(userId);
  }

  static Future<void> saveTokenForUser(String userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      await FirebaseFirestore.instance
          .collection(BackendEndpoints.getUserData)
          .doc(userId)
          .set({
            'fcmToken': token,
            'fcmTokens': FieldValue.arrayUnion([token]),
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  static void _listenToTokenChanges() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty || token.isEmpty) return;

      try {
        await FirebaseFirestore.instance
            .collection(BackendEndpoints.getUserData)
            .doc(userId)
            .set({
              'fcmToken': token,
              'fcmTokens': FieldValue.arrayUnion([token]),
              'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to refresh FCM token: $e');
      }
    });
  }

  static void _listenToAuthChanges() {
    if (_authListenerStarted) return;
    _authListenerStarted = true;

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) return;
      saveTokenForUser(user.uid);
    });
  }

  static void _handleMessage(RemoteMessage message) {
    final gameId = message.data['gameId']?.toString();
    if (gameId == null || gameId.isEmpty) return;

    final navigator = DeepLinkService.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamed(Routes.gameDetailsById, arguments: gameId);
  }
}
