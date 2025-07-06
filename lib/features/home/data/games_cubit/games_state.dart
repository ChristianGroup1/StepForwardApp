part of 'games_cubit.dart';

@immutable
sealed class GamesState {}

final class GamesInitialState extends GamesState {}

final class GetGamesLoadingState extends GamesState {}
final class GetGamesSuccessState extends GamesState {
  final List<GameModel> games;
  GetGamesSuccessState({ required this.games});
}
final class GetGameFailureState extends GamesState {
  final String errorMessage;
  GetGameFailureState({required this.errorMessage});
}



final class AddGameToFavoritesSuccessState extends GamesState {}

final class AddGameToFavoritesFailureState extends GamesState {
  final String errorMessage;
  AddGameToFavoritesFailureState({required this.errorMessage});
}
class HomeFavoritesUpdated extends GamesState {}

final class RemoveGameFromFavoritesSuccessState extends GamesState {}
final class RemoveGameFromFavoritesFailureState extends GamesState {
  final String errorMessage;
  RemoveGameFromFavoritesFailureState({required this.errorMessage});
}
final class SearchGameSuccessState extends GamesState {
  final List<GameModel> games;
  SearchGameSuccessState({required this.games});

}
final class SearchGameFailureState extends GamesState {
  final String errorMessage;
  SearchGameFailureState({required this.errorMessage});
}


final class FetchUserFavoritesSuccessState extends GamesState {
  final List<GameModel> favorites;
  FetchUserFavoritesSuccessState({required this.favorites});
}
final class FetchUserFavoritesLoadingState extends GamesState {}
final class FetchUserFavoritesFailureState extends GamesState {
  final String errorMessage;
  FetchUserFavoritesFailureState({required this.errorMessage});
}

final class GetBooksFailureState extends GamesState {
  final String errorMessage;
  GetBooksFailureState({required this.errorMessage});
}

final class GetBooksSuccessState extends GamesState {
  final List<BookModel> books;
  GetBooksSuccessState({required this.books});
}

final class GetBooksLoadingState extends GamesState {}

