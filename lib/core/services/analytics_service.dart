import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> logScreenView({required String screenName}) async {
    await analytics.logScreenView(screenName: screenName);
  }

  static Future<void> logLogin({required String method}) async {
    await analytics.logLogin(loginMethod: method);
  }

  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
