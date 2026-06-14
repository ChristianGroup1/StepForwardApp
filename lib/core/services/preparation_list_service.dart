import 'dart:convert';

import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';

class PreparationListService {
  List<GameModel> getGames() {
    final cachedData = CacheHelper.getData(key: kPreparationGamesKey);
    if (cachedData is! String || cachedData.isEmpty) return [];

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map((item) => GameModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  bool containsGame(String gameId) {
    return getGames().any((game) => game.id == gameId);
  }

  Future<void> addGame(GameModel game) async {
    final games = getGames();
    final exists = games.any((item) => item.id == game.id);
    if (!exists) games.add(game);
    await _saveGames(games);
  }

  Future<void> removeGame(String gameId) async {
    final games = getGames()..removeWhere((game) => game.id == gameId);
    await _saveGames(games);
  }

  Future<void> clearGames() async {
    await CacheHelper.removeData(key: kPreparationGamesKey);
    await CacheHelper.removeData(key: kPreparationCheckedToolsKey);
  }

  Set<String> getCheckedTools() {
    final cachedData = CacheHelper.getData(key: kPreparationCheckedToolsKey);
    if (cachedData is! String || cachedData.isEmpty) return {};

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! List) return {};
      return decoded.map((item) => item.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> setToolChecked({
    required String toolKey,
    required bool checked,
  }) async {
    final checkedTools = getCheckedTools();
    if (checked) {
      checkedTools.add(toolKey);
    } else {
      checkedTools.remove(toolKey);
    }

    await CacheHelper.saveData(
      key: kPreparationCheckedToolsKey,
      value: jsonEncode(checkedTools.toList()),
    );
  }

  Future<void> _saveGames(List<GameModel> games) async {
    await CacheHelper.saveData(
      key: kPreparationGamesKey,
      value: jsonEncode(games.map((game) => game.toJson()).toList()),
    );
  }
}

final preparationListService = PreparationListService();
