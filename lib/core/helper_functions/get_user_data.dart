import 'dart:convert';

import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';

UserModel getUserData() {
  final cachedUser = getCachedUserData();
  if (cachedUser == null) {
    throw StateError('No cached user data found');
  }
  return cachedUser;
}

UserModel? getCachedUserData() {
  final cachedData = CacheHelper.getData(key: kSaveUserDataKey);
  if (cachedData is! String || cachedData.isEmpty) return null;

  try {
    final decoded = jsonDecode(cachedData);
    if (decoded is! Map<String, dynamic>) return null;
    return UserModel.fromJson(decoded);
  } catch (_) {
    return null;
  }
}

bool hasCachedUserData() => getCachedUserData() != null;
