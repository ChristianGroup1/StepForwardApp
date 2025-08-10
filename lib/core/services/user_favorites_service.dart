// lib/core/services/user_favorites_service.dart
import 'package:flutter/foundation.dart';

class UserFavoritesService {
  static final UserFavoritesService _instance = UserFavoritesService._internal();
  factory UserFavoritesService() => _instance;
  UserFavoritesService._internal();

  final ValueNotifier<List<String>> userFavoritesNotifier = ValueNotifier([]);
}

final userFavoritesService = UserFavoritesService();
