import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/domain/models/brothers_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';

part 'brothers_state.dart';

class BrothersCubit extends Cubit<BrothersState> {
  final HomeRepo homeRepo;
  final AuthRepo authRepo;
  List<BrothersModel> allBrothers = [];
  List<String> selectedTags = [];
  final TextEditingController searchController = TextEditingController();

  BrothersCubit(this.homeRepo, this.authRepo) : super(BrothersInitialState());

  Future<void> getBrothers() async {
    emit(GetBrothersLoadingState());
    final result = await homeRepo.getAllBrothers();
    result.fold(
      (failure) => emit(GetBrothersFailureState(errorMessage: failure.message)),
      (brothers) {
        allBrothers = brothers;
        emit(GetBrothersSuccessState(brothers: _filteredBrothers()));
      },
    );
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    emit(GetBrothersSuccessState(brothers: _filteredBrothers()));
  }

  List<BrothersModel> _filteredBrothers() {
    if (selectedTags.isEmpty) return allBrothers;
    return allBrothers.where((bro) {
      return bro.tags.any((tag) => selectedTags.contains(tag));
    }).toList();
  }

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

  Future<void> searchBrothers() async {
    emit(GetBrothersLoadingState());
    final result = await homeRepo.searchBrothers(searchController.text);
    result.fold(
      (failure) => emit(GetBrothersFailureState(errorMessage: failure.message)),
      (brothers) {
        allBrothers = brothers;
        emit(GetBrothersSuccessState(brothers: _filteredBrothers()));
      },
    );
  }
}
