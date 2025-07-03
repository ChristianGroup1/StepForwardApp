import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;
    final AuthRepo authRepo ;
  List<String> userFavorites = [];
    List<GameModel> allGames = [];
  List<String> selectedTags = [];
  final TextEditingController searchController = TextEditingController();
  HomeCubit(this.homeRepo,this.authRepo) : super(HomeInitialState());

  Future<void> getGames() async {
    emit(GetGamesLoadingState());

    // 1. Fetch user favorites
    final favoritesResult = await homeRepo
        .getUserFavorites(); // you'll implement this
    if (favoritesResult.isLeft()) {
      emit(
        GetGameFailureState(
          errorMessage: favoritesResult
              .swap()
              .getOrElse(() => CustomFailure(message: 'Error'))
              .message,
        ),
      );
      return;
    }

    userFavorites = favoritesResult.getOrElse(() => []);

    // 2. Fetch all games
    final result = await homeRepo.getGames();
    result.fold(
      (failure) => emit(GetGameFailureState(errorMessage: failure.message)),
      (games) {
        allGames = games;
        emit(GetGamesSuccessState(games: _filteredGames()));
      },  
    );
  }

  Future<void> changeGameFavoriteState({required String gameId}) async {
    final isAlreadyFavorite = userFavorites.contains(gameId);

    if (isAlreadyFavorite) {
      userFavorites.remove(gameId);
    } else {
      userFavorites.add(gameId);
      emit(HomeFavoritesUpdated());
    }
    final result = await homeRepo.changeGameFavoriteState(gameId: gameId);

    result.fold(
      (failure) {
        if (isAlreadyFavorite) {
          userFavorites.add(gameId);
          emit(HomeFavoritesUpdated());
        } else {
          userFavorites.remove(gameId);
        }
        emit(AddGameToFavoritesFailureState(errorMessage: failure.message));
      },
      (value) {
        // Success
        if (isAlreadyFavorite) {
          emit(RemoveGameFromFavoritesSuccessState());
        } else {
          emit(AddGameToFavoritesSuccessState());
        }
      },
    );
  }
  Future<void>searchGames()async{
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

  Future<void> getUserApprovedDataIfNotApproved() async {
    final cachedUser = getUserData();

    if (!cachedUser.isApproved) {
      try {
        final freshUser = await authRepo.getUserData(id: cachedUser.id);
        freshUser.isApproved
            ? await authRepo.saveUserData(userModel: freshUser)
            : null;

        log('the state is ${freshUser.isApproved}');
      } catch (e) {
        debugPrint('Failed to fetch or save updated user data: $e');
      }
    }
  }

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
}
