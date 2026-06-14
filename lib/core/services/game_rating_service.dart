import 'dart:convert';

import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';

class GameRatingService {
  int getRating(String gameId) {
    final ratings = _readRatings();
    return ratings[gameId] ?? 0;
  }

  Future<void> saveRating({required String gameId, required int rating}) async {
    final sanitizedRating = rating.clamp(1, 5);
    final ratings = _readRatings();
    ratings[gameId] = sanitizedRating;

    await CacheHelper.saveData(
      key: kGameRatingsKey,
      value: jsonEncode(ratings),
    );
  }

  Map<String, int> _readRatings() {
    final cachedData = CacheHelper.getData(key: kGameRatingsKey);
    if (cachedData is! String || cachedData.isEmpty) return {};

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! Map) return {};

      return decoded.map((key, value) {
        final parsedValue = value is int
            ? value
            : int.tryParse(value.toString()) ?? 0;
        return MapEntry(key.toString(), parsedValue.clamp(0, 5));
      });
    } catch (_) {
      return {};
    }
  }
}
