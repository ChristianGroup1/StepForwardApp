import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/services/database_service.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
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
      var gamesList = games.map((e) => GameModel.fromJson(e)).toList();
      return right(gamesList);
    } catch (e) {
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

      await databaseService.updateData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
        data: {
          'favorites': isAlreadyFavorite
              ? FieldValue.arrayRemove([gameId])
              : FieldValue.arrayUnion([gameId]),
        },
      );

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
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameModel>>> searchGames(
    String searchText,
  ) async {
    try {
      var data = await databaseService.searchData(searchText,BackendEndpoints.getGames);
      return right(data.map((e) => GameModel.fromJson(e)).toList());
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

   @override
  Future<Either<Failure, List<BrothersModel>>> searchBrothers(
    String searchText,
  ) async {
    try {
      var data = await databaseService.searchData(searchText,BackendEndpoints.getBrothers);
      return right(data.map((e) => BrothersModel.fromJson(e)).toList());
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

      final games = await Future.wait(gamesFutures);

      return Right(games);
    } catch (e) {
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
      return right(brothersList);
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookModel>>> getBooks()async {
    try {
      var booksData =
          await databaseService.getData(path: BackendEndpoints.getBooks)
              as List<Map<String, dynamic>>;
      var booksList = booksData
          .map((e) => BookModel.fromJson(e))
          .toList();
      return right(booksList);
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }
}
