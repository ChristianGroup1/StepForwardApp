import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/services/database_service.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/home/domain/models/book_model.dart';
import 'package:stepforward/features/home/domain/models/brothers_model.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';

class HomeRepoImpl extends HomeRepo {
  final DatabaseService databaseService;

  HomeRepoImpl({required this.databaseService});
  @override
  Future<Either<Failure, List<GameModel>>> getGames() async {
    try {
      var games =
          await databaseService.getData(path: BackendEndpoints.getGames)
              as List<Map<String, dynamic>>;
      var gamesList = _visibleGames(
        games.map((e) => GameModel.fromJson(e)).toList(),
      );
      await _cacheList(kCachedGamesKey, gamesList.map((e) => e.toJson()));
      return right(gamesList);
    } catch (e) {
      final cachedGames = _visibleGames(
        _readCachedList(kCachedGamesKey, (json) => GameModel.fromJson(json)),
      );
      if (cachedGames.isNotEmpty) return right(cachedGames);

      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changeGameFavoriteState({
    required String gameId,
  }) async {
    try {
      final userId = getUserData().id;

      // Get user document
      final userDoc = await FirebaseFirestore.instance
          .collection(BackendEndpoints.getUserData)
          .doc(userId)
          .get();

      final List<dynamic> currentFavorites = userDoc.data()?['favorites'] ?? [];

      final bool isAlreadyFavorite = currentFavorites.contains(gameId);
      final shouldAddFavorite = !isAlreadyFavorite;

      await databaseService.updateData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
        data: {
          'favorites': isAlreadyFavorite
              ? FieldValue.arrayRemove([gameId])
              : FieldValue.arrayUnion([gameId]),
        },
      );

      await _syncCachedFavoriteIds(gameId, shouldAdd: shouldAddFavorite);
      await _syncCachedFavoriteGame(gameId, shouldAdd: shouldAddFavorite);

      return right(null);
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUserFavoritesIDs() async {
    try {
      final userId = getUserData().id;
      final userData =
          await databaseService.getData(
                path: BackendEndpoints.getUserData,
                documentId: userId,
              )
              as Map<String, dynamic>;

      final favorites = List<String>.from(userData['favorites'] ?? []);
      return right(favorites);
    } catch (e) {
      final cachedUser = getCachedUserData();
      if (cachedUser?.favorites != null) {
        return right(cachedUser!.favorites!);
      }

      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameModel>>> searchGames(
    String searchText,
  ) async {
    try {
      final results = await databaseService.searchData(
        searchText,
        BackendEndpoints.getGames,
      );
      return right(_visibleGames(results.map((e) => GameModel.fromJson(e))));
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BrothersModel>>> searchBrothers(
    String searchText,
  ) async {
    try {
      final results = await databaseService.searchData(
        searchText,
        BackendEndpoints.getBrothers,
      );
      final brothersList = results
          .map((e) => BrothersModel.fromJson(e))
          .toList();
      return right(brothersList);
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameModel>>> getUserFavorites({
    required String userId,
  }) async {
    try {
      final userDoc = await databaseService.getData(
        path: BackendEndpoints.getUserFavorites,
        documentId: userId,
      );

      final List<dynamic> favoriteIds = userDoc['favorites'] ?? [];

      final gamesFutures = favoriteIds.map((gameId) async {
        final gameDoc = await databaseService.getData(
          path: BackendEndpoints.getGames,
          documentId: gameId,
        );
        return GameModel.fromJson({...gameDoc, 'id': gameId});
      });

      final games = _visibleGames(await Future.wait(gamesFutures));
      await _cacheList(kCachedFavoriteGamesKey, games.map((e) => e.toJson()));

      return Right(games);
    } catch (e) {
      final cachedFavoriteGames = _readCachedList(
        kCachedFavoriteGamesKey,
        (json) => GameModel.fromJson(json),
      );
      final visibleCachedFavoriteGames = _visibleGames(cachedFavoriteGames);
      if (visibleCachedFavoriteGames.isNotEmpty) {
        return right(visibleCachedFavoriteGames);
      }

      return Left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeGameFromFavorites({
    required String gameId,
  }) async {
    try {
      final userId = getUserData().id;

      await databaseService.updateData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
        data: {
          'favorites': FieldValue.arrayRemove([gameId]),
        },
      );

      await _syncCachedFavoriteIds(gameId, shouldAdd: false);
      await _syncCachedFavoriteGame(gameId, shouldAdd: false);

      return right(null);
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BrothersModel>>> getBrothers() async {
    try {
      var brothersData =
          await databaseService.getData(path: BackendEndpoints.getBrothers)
              as List<Map<String, dynamic>>;
      var brothersList = brothersData
          .map((e) => BrothersModel.fromJson(e))
          .toList();
      await _cacheList(kCachedBrothersKey, brothersList.map((e) => e.toJson()));
      return right(brothersList);
    } catch (e) {
      final cachedBrothers = _readCachedList(
        kCachedBrothersKey,
        (json) => BrothersModel.fromJson(json),
      );
      if (cachedBrothers.isNotEmpty) return right(cachedBrothers);

      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookModel>>> getBooks() async {
    try {
      var booksData =
          await databaseService.getData(path: BackendEndpoints.getBooks)
              as List<Map<String, dynamic>>;
      var booksList = booksData.map((e) => BookModel.fromJson(e)).toList();
      await _cacheList(kCachedBooksKey, booksList.map((e) => e.toJson()));
      return right(booksList);
    } catch (e) {
      final cachedBooks = _readCachedList(
        kCachedBooksKey,
        (json) => BookModel.fromJson(json),
      );
      if (cachedBooks.isNotEmpty) return right(cachedBooks);

      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GameModel>> getGameById(String gameId) async {
    try {
      final data =
          await databaseService.getData(
                path: BackendEndpoints.getGames,
                documentId: gameId,
              )
              as Map<String, dynamic>;
      final game = GameModel.fromJson({...data, 'id': gameId});
      if (!game.isVisible) {
        return left(CustomFailure(message: 'Game is not visible'));
      }
      return right(game);
    } catch (e) {
      final cachedGames = _visibleGames(
        _readCachedList(kCachedGamesKey, (json) => GameModel.fromJson(json)),
      );
      final matchingGames = cachedGames.where((game) => game.id == gameId);
      if (matchingGames.isNotEmpty) return right(matchingGames.first);

      return left(CustomFailure(message: e.toString()));
    }
  }

  Future<void> _cacheList(
    String key,
    Iterable<Map<String, dynamic>> values,
  ) async {
    await CacheHelper.saveData(key: key, value: jsonEncode(values.toList()));
  }

  List<GameModel> _visibleGames(Iterable<GameModel> games) {
    return games.where((game) => game.isVisible).toList();
  }

  List<T> _readCachedList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final cachedData = CacheHelper.getData(key: key);
    if (cachedData is! String || cachedData.isEmpty) return [];

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _syncCachedFavoriteGame(
    String gameId, {
    required bool shouldAdd,
  }) async {
    final cachedFavorites = _readCachedList(
      kCachedFavoriteGamesKey,
      (json) => GameModel.fromJson(json),
    );
    cachedFavorites.removeWhere((game) => game.id == gameId);

    if (shouldAdd) {
      final cachedGames = _readCachedList(
        kCachedGamesKey,
        (json) => GameModel.fromJson(json),
      );
      final matchingGames = cachedGames.where((game) => game.id == gameId);
      if (matchingGames.isNotEmpty) cachedFavorites.add(matchingGames.first);
    }

    await _cacheList(
      kCachedFavoriteGamesKey,
      cachedFavorites.map((game) => game.toJson()),
    );
  }

  Future<void> _syncCachedFavoriteIds(
    String gameId, {
    required bool shouldAdd,
  }) async {
    final cachedData = CacheHelper.getData(key: kSaveUserDataKey);
    if (cachedData is! String || cachedData.isEmpty) return;

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! Map) return;

      final userData = Map<String, dynamic>.from(decoded);
      final favorites = List<String>.from(userData['favorites'] ?? []);
      if (shouldAdd) {
        if (!favorites.contains(gameId)) favorites.add(gameId);
      } else {
        favorites.remove(gameId);
      }
      userData['favorites'] = favorites;

      await CacheHelper.saveData(
        key: kSaveUserDataKey,
        value: jsonEncode(userData),
      );
    } catch (_) {}
  }
}
