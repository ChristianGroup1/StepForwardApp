import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/services/user_favorites_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/domain/models/book_model.dart';
import 'package:stepforward/features/home/domain/models/brothers_model.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';

part 'games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  final HomeRepo homeRepo;
  final AuthRepo authRepo;

  List<GameModel> allGames = [];
  List<String> selectedTags = [];
  String? selectedTarget;
  List<BrothersModel> allBrothers = [];

  final TextEditingController searchController = TextEditingController();

  GamesCubit(this.homeRepo, this.authRepo) : super(GamesInitialState());

  // Fetch games and sync favorites
  Future<void> getGames() async {
    emit(GetGamesLoadingState());

    // Step 1: Load favorites
    final favoritesResult = await homeRepo.getUserFavoritesIDs();
    final favorites = favoritesResult.getOrElse(() => []);
    userFavoritesService.userFavoritesNotifier.value = favorites;

    // Step 2: Load all games
    final result = await homeRepo.getGames();
    result.fold(
      (failure) => emit(GetGameFailureState(errorMessage: failure.message)),
      (games) {
        allGames = _sortNewestFirst(games);
        emit(GetGamesSuccessState(games: _filteredGames()));
      },
    );
  }

  // Fetch all brothers

  // Toggle favorite state
  Future<void> changeGameFavoriteState({required String gameId}) async {
    final favorites = userFavoritesService.userFavoritesNotifier.value;
    final isFavorite = favorites.contains(gameId);

    final updated = List<String>.from(favorites);
    if (isFavorite) {
      updated.remove(gameId);
    } else {
      updated.add(gameId);
    }
    userFavoritesService.userFavoritesNotifier.value = updated;

    final result = await homeRepo.changeGameFavoriteState(gameId: gameId);
    result.fold(
      (failure) {
        // Revert on failure
        if (isFavorite) {
          updated.add(gameId);
        } else {
          updated.remove(gameId);
        }
        userFavoritesService.userFavoritesNotifier.value = updated;

        emit(AddGameToFavoritesFailureState(errorMessage: failure.message));
      },
      (_) {
        emit(
          isFavorite
              ? RemoveGameFromFavoritesSuccessState()
              : AddGameToFavoritesSuccessState(),
        );
      },
    );
  }

  // Search games locally by target without changing Firestore data.
  void searchGames() {
    emit(GetGamesSuccessState(games: _filteredGames()));
  }

  List<String> get availableTargets {
    final targets = allGames
        .expand((game) => game.filterTargets)
        .where((target) => target.isNotEmpty)
        .toSet()
        .toList();
    targets.sort();
    return targets;
  }

  // Refresh user data if not approved
  Future<void> getUserApprovedDataIfNotApproved() async {
    final cachedUser = getUserData();

    if (!cachedUser.isApproved) {
      try {
        final freshUser = await authRepo.getUserData(id: cachedUser.id);
        if (freshUser.isApproved) {
          await authRepo.saveUserData(userModel: freshUser);
        }
      } catch (e) {
        debugPrint('Failed to refresh approval data: $e');
      }
    }
  }

  // Toggle a filter tag
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }

    emit(GetGamesSuccessState(games: _filteredGames()));
  }

  void selectTarget(String target) {
    selectedTarget = selectedTarget == target ? null : target;
    emit(GetGamesSuccessState(games: _filteredGames()));
  }

  void clearFilters() {
    selectedTags.clear();
    selectedTarget = null;
    searchController.clear();
    emit(GetGamesSuccessState(games: _filteredGames()));
  }

  List<GameModel> _filteredGames() {
    final normalizedSearch = _normalize(searchController.text);
    final normalizedSelectedTarget = _normalize(selectedTarget ?? '');

    return allGames.where((game) {
      final normalizedGoalTags = game.filterTargets.map(_normalize).toList();
      final matchesTags =
          selectedTags.isEmpty ||
          game.tags.any((tag) => selectedTags.contains(tag));
      final matchesSelectedTarget =
          normalizedSelectedTarget.isEmpty ||
          normalizedGoalTags.contains(normalizedSelectedTarget);
      final matchesTarget =
          normalizedSearch.isEmpty ||
          normalizedGoalTags.any((tag) => tag.contains(normalizedSearch));

      return matchesTags && matchesSelectedTarget && matchesTarget;
    }).toList();
  }

  bool isNewestGame(GameModel game) {
    if (allGames.isEmpty) return false;

    final newestDate = allGames.first.createdAt;
    if (newestDate == null) return game.id == allGames.first.id;

    return game.createdAt != null &&
        game.createdAt!.isAtSameMomentAs(newestDate);
  }

  List<GameModel> _sortNewestFirst(List<GameModel> games) {
    return List<GameModel>.from(games)..sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  // Fetch games that are marked as favorites
  Future<void> fetchUserFavorites() async {
    emit(FetchUserFavoritesLoadingState());
    final result = await homeRepo.getUserFavorites(userId: getUserData().id);
    result.fold(
      (failure) =>
          emit(FetchUserFavoritesFailureState(errorMessage: failure.message)),
      (favorites) => emit(FetchUserFavoritesSuccessState(favorites: favorites)),
    );
  }

  // Remove game from favorites (Favorites View)
  Future<void> removeGameFromFavorites(String gameId) async {
    final result = await homeRepo.removeGameFromFavorites(gameId: gameId);
    result.fold(
      (failure) => emit(
        RemoveGameFromFavoritesFailureState(errorMessage: failure.message),
      ),
      (_) {
        final updated = List<String>.from(
          userFavoritesService.userFavoritesNotifier.value,
        );
        updated.remove(gameId);
        userFavoritesService.userFavoritesNotifier.value = updated;
        emit(RemoveGameFromFavoritesSuccessState());
      },
    );
  }

  Future<void> getBooks() async {
    emit(GetBooksLoadingState());

    final result = await homeRepo.getBooks();
    result.fold(
      (failure) => emit(GetBooksFailureState(errorMessage: failure.message)),
      (books) => emit(GetBooksSuccessState(books: books)),
    );
  }
}
