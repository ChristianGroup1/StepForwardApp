import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/rouutes.dart';
import 'package:stepforward/core/services/firebase_auth_service.dart';

/// Handles incoming deep links with the scheme `stepforward://game/{gameId}`.
///
/// Usage:
///   1. Call [DeepLinkService.init] in `main()` after Firebase is initialised.
///   2. Assign [navigatorKey] to `MaterialApp.navigatorKey`.
///   3. Call [navigatePendingIfAny] from `MainView.initState` so that links
///      received before the user was authenticated are handled after login.
class DeepLinkService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  /// If a deep link arrived before the user was authenticated, we store the
  /// game ID here so MainView can handle it after login.
  static String? _pendingGameId;

  /// Initialises the service.  Call once in `main()`.
  static Future<void> init() async {
    try {
      // Cold-start: app was launched via a deep link.
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLinkService init error: $e');
    }

    // Warm-start: app was already running when the link was tapped.
    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('DeepLinkService stream error: $e'),
    );
  }

  /// Call this from `MainView.initState` (after the user has logged in) to
  /// navigate to a game that was requested before authentication was ready.
  static void navigatePendingIfAny(BuildContext context) {
    if (_pendingGameId != null) {
      final id = _pendingGameId!;
      _pendingGameId = null;
      Navigator.of(context).pushNamed(Routes.gameDetailsById, arguments: id);
    }
  }

  /// Releases the stream subscription.
  static void dispose() => _sub?.cancel();

  // ── Private helpers ────────────────────────────────────────────────────────

  static void _handleUri(Uri uri) {
    if (uri.scheme != 'stepforward') return;
    if (uri.host != 'game') return;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return;
    final gameId = segments.first;
    if (gameId.isEmpty) return;

    debugPrint('DeepLinkService: received link for game $gameId');
    _navigateToGame(gameId);
  }

  static void _navigateToGame(String gameId) {
    final nav = navigatorKey.currentState;
    if (nav == null || !FirebaseAuthService().isLoggedIn()) {
      // Navigator not ready or user not logged in — save for later.
      _pendingGameId = gameId;
      return;
    }
    nav.pushNamed(Routes.gameDetailsById, arguments: gameId);
  }
}
