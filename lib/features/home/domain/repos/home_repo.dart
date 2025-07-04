import 'package:dartz/dartz.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';

abstract class HomeRepo{
  Future<Either<Failure,List<GameModel>>>getGames();
  Future<Either<Failure,void>>changeGameFavoriteState({required String gameId});
  Future<Either<Failure, List<String>>> getUserFavoritesIDs();
   Future<Either<Failure, List<GameModel>>> searchGames(String searchText);
     Future<Either<Failure, List<GameModel>>>  getUserFavorites({required String userId});
Future<Either<Failure, void>> removeGameFromFavorites({required String gameId});

}