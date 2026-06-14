import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/services/game_rating_service.dart';

void main() {
  test('GameRatingService saves and restores game ratings', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    final service = GameRatingService();

    expect(service.getLocalRating('game-1'), 0);

    await service.saveRating(gameId: 'game-1', rating: 4);

    expect(service.getLocalRating('game-1'), 4);
    expect(service.getLocalRating('game-2'), 0);
  });

  test('GameRatingService clamps rating between 1 and 5', () async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    final service = GameRatingService();

    await service.saveRating(gameId: 'game-1', rating: 9);
    await service.saveRating(gameId: 'game-2', rating: -1);

    expect(service.getLocalRating('game-1'), 5);
    expect(service.getLocalRating('game-2'), 1);
  });
}
