import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/services/user_favorites_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;
  final AuthRepo authRepo;

  List<GameModel> allGames = [];
  List<String> selectedTags = [];

  final TextEditingController searchController = TextEditingController();

  HomeCubit(this.homeRepo, this.authRepo) : super(HomeInitialState());

  // Fetch games and sync favorites
  Future<void> getGames() async {
    emit(GetGamesLoadingState());

    // Step 1: Load favorites
    final favoritesResult = await homeRepo.getUserFavoritesIDs();
    if (favoritesResult.isLeft()) {
      emit(GetGameFailureState(
        errorMessage: favoritesResult.fold(
          (l) => l.message,
          (r) => '',
        ),
      ));
      return;
    }

    final favorites = favoritesResult.getOrElse(() => []);
    userFavoritesService.userFavoritesNotifier.value = favorites;

    // Step 2: Load all games
    final result = await homeRepo.getGames();
    result.fold(
      (failure) => emit(GetGameFailureState(errorMessage: failure.message)),
      (games) {
        allGames = games;
        emit(GetGamesSuccessState(games: _filteredGames()));
      },
    );
  }

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
        emit(isFavorite
            ? RemoveGameFromFavoritesSuccessState()
            : AddGameToFavoritesSuccessState());
      },
    );
  }

  // Search games
  Future<void> searchGames() async {
    emit(GetGamesLoadingState());
    final result = await homeRepo.searchGames(searchController.text);
    result.fold(
      (failure) => emit(GetGameFailureState(errorMessage: failure.message)),
      (games) {
        allGames = games;
        emit(GetGamesSuccessState(games: _filteredGames()));
      },
    );
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
        log('Account approval status: ${freshUser.isApproved}');
      } catch (e) {
        debugPrint('Failed to fetch user data: $e');
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

  List<GameModel> _filteredGames() {
    if (selectedTags.isEmpty) return allGames;
    return allGames.where((game) {
      return game.tags.any((tag) => selectedTags.contains(tag));
    }).toList();
  }

  // Fetch games that are marked as favorites
  Future<void> fetchUserFavorites() async {
    emit(FetchUserFavoritesLoadingState());
    final result = await homeRepo.getUserFavorites(userId: getUserData().id);
    result.fold(
      (failure) => emit(FetchUserFavoritesFailureState(errorMessage: failure.message)),
      (favorites) => emit(FetchUserFavoritesSuccessState(favorites: favorites)),
    );
  }

  // Remove game from favorites (Favorites View)
  Future<void> removeGameFromFavorites(String gameId) async {
    final result = await homeRepo.removeGameFromFavorites(gameId: gameId);
    result.fold(
      (failure) => emit(RemoveGameFromFavoritesFailureState(errorMessage: failure.message)),
      (_) {
        final updated = List<String>.from(userFavoritesService.userFavoritesNotifier.value);
        updated.remove(gameId);
        userFavoritesService.userFavoritesNotifier.value = updated;
        emit(RemoveGameFromFavoritesSuccessState());
      },
    );
  }
}
