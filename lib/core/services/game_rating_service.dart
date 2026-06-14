import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';

class GameRatingService {
  int getLocalRating(String gameId) {
    final ratings = _readRatings();
    return ratings[gameId] ?? 0;
  }

  Future<int> getRating(String gameId) async {
    try {
      final userId = getUserData().id;
      final ratingDoc = await FirebaseFirestore.instance
          .collection(BackendEndpoints.getGames)
          .doc(gameId)
          .collection('ratings')
          .doc(userId)
          .get();

      final rating = _parseRating(ratingDoc.data()?['rating']);
      if (rating > 0) {
        await _saveLocalRating(gameId: gameId, rating: rating);
        return rating;
      }
    } catch (_) {}

    return getLocalRating(gameId);
  }

  Future<bool> saveRating({required String gameId, required int rating}) async {
    final sanitizedRating = rating.clamp(1, 5);
    await _saveLocalRating(gameId: gameId, rating: sanitizedRating);

    try {
      final userId = getUserData().id;
      final firestore = FirebaseFirestore.instance;
      final gameRef = firestore
          .collection(BackendEndpoints.getGames)
          .doc(gameId);
      final ratingRef = gameRef.collection('ratings').doc(userId);

      await firestore.runTransaction((transaction) async {
        final ratingSnapshot = await transaction.get(ratingRef);
        final gameSnapshot = await transaction.get(gameRef);

        final previousRating = ratingSnapshot.exists
            ? _parseRating(ratingSnapshot.data()?['rating'])
            : 0;
        final gameData = gameSnapshot.data() ?? {};
        final currentSum = _parseInt(gameData['ratingSum']);
        final currentCount = _parseInt(gameData['ratingCount']);
        final nextSum = currentSum - previousRating + sanitizedRating;
        final nextCount = previousRating == 0 ? currentCount + 1 : currentCount;

        transaction.set(ratingRef, {
          'rating': sanitizedRating,
          'userId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(gameRef, {
          'ratingSum': nextSum,
          'ratingCount': nextCount,
          'ratingAverage': nextCount == 0 ? 0 : nextSum / nextCount,
        }, SetOptions(merge: true));
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveLocalRating({
    required String gameId,
    required int rating,
  }) async {
    final ratings = _readRatings();
    ratings[gameId] = rating.clamp(1, 5);

    await CacheHelper.saveData(
      key: kGameRatingsKey,
      value: jsonEncode(ratings),
    );
  }

  int _parseRating(dynamic value) {
    return _parseInt(value).clamp(0, 5);
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, int> _readRatings() {
    final cachedData = CacheHelper.getData(key: kGameRatingsKey);
    if (cachedData is! String || cachedData.isEmpty) return {};

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! Map) return {};

      return decoded.map((key, value) {
        final parsedValue = _parseInt(value);
        return MapEntry(key.toString(), parsedValue.clamp(0, 5));
      });
    } catch (_) {
      return {};
    }
  }
}
