part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitialState extends HomeState {}

final class GetGamesLoadingState extends HomeState {}
final class GetGamesSuccessState extends HomeState {
  final List<GameModel> games;
  GetGamesSuccessState({ required this.games});
}
final class GetGameFailureState extends HomeState {
  final String errorMessage;
  GetGameFailureState({required this.errorMessage});
}

final class AddGameToFavoritesSuccessState extends HomeState {}

final class AddGameToFavoritesFailureState extends HomeState {
  final String errorMessage;
  AddGameToFavoritesFailureState({required this.errorMessage});
}
class HomeFavoritesUpdated extends HomeState {}

final class RemoveGameFromFavoritesSuccessState extends HomeState {}
final class SearchGameSuccessState extends HomeState {
  final List<GameModel> games;
  SearchGameSuccessState({required this.games});

}
final class SearchGameFailureState extends HomeState {
  final String errorMessage;
  SearchGameFailureState({required this.errorMessage});
}
