import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/repos/image_repo.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/domain/models/brothers_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
part 'brothers_state.dart';

class BrothersCubit extends Cubit<BrothersState> {
  final HomeRepo homeRepo;
  final AuthRepo authRepo;
  final ImagesRepo imagesRepo;
  List<BrothersModel> allBrothers = [];
  List<String> selectedTags = [];
  final TextEditingController searchController = TextEditingController();
  String selectedGovernment = getUserData().government;
  String selectedDenomination = 'الكل';
  bool isEmailVerified = false;
  File? frontId;
  File? backId;
  final TextEditingController frontIdController = TextEditingController();
  final TextEditingController backIdController = TextEditingController();

  BrothersCubit(this.homeRepo, this.authRepo, this.imagesRepo)
    : super(BrothersInitialState());

  Future<void> getBrothers() async {
    emit(GetBrothersLoadingState());
    final result = await homeRepo.getBrothers();
    result.fold(
      (failure) => emit(GetBrothersFailureState(errorMessage: failure.message)),
      (brothers) {
        allBrothers = brothers;
        emit(GetBrothersSuccessState(brothers: _filteredBrothers()));
      },
    );
  }

  void changeGovernment(String government) {
    selectedGovernment = government;
    emit(
      GetBrothersSuccessState(
        brothers: government == 'الكل' ? allBrothers : _filteredBrothers(),
      ),
    );
  }

  void changeDenomination(String denomination) {
    selectedDenomination = denomination;
    emit(
      GetBrothersSuccessState(
        brothers: denomination == 'الكل' ? allBrothers : _filteredBrothers(),
      ),
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

  void checkAndToastIfNotVerified() async {
    if (!isEmailVerified) {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      isEmailVerified = updatedUser?.emailVerified ?? false;

      emit(CheckUserEmailVerification(isVerified: isEmailVerified));
    }
  }

  List<BrothersModel> _filteredBrothers() {
    return allBrothers.where((brother) {
      final tagMatch =
          selectedTags.isEmpty ||
          brother.tags.any((tag) => selectedTags.contains(tag));
      final govMatch =
          selectedGovernment == 'الكل' ||
          brother.government == selectedGovernment;
      final denominationMatch =
          selectedDenomination == 'الكل' ||
          brother.denomination == selectedDenomination;
      final visibilityMatch = brother.isVisible == true;

      return tagMatch && govMatch && denominationMatch && visibilityMatch;
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
      } catch (e) {
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

  Future<void> addUserIds() async {
  if (frontId == null || backId == null) {
    emit(AddUserIdsFailureState(errorMessage: "برجاء رفع صور الوجه والظهر"));
    return;
  }

  emit(AddUserIdsLoadingState());

  final frontUploadResult = await imagesRepo.uploadImage(image: frontId!);
  await frontUploadResult.fold(
    (failure) async {
      emit(AddUserIdsFailureState(errorMessage: failure.message));
    },
    (uploadedFrontId) async {
      frontIdController.text = uploadedFrontId;

      final backUploadResult = await imagesRepo.uploadImage(image: backId!);
      await backUploadResult.fold(
        (failure) async {
          emit(AddUserIdsFailureState(errorMessage: failure.message));
        },
        (uploadedBackId) async {
          backIdController.text = uploadedBackId;

          final addUserIdResult = await authRepo.addUserIds(
            uId: getUserData().id ,
            frontId: uploadedFrontId,
            backId: uploadedBackId,
          );

          addUserIdResult.fold(
            (failure) => emit(AddUserIdsFailureState(errorMessage: failure.message)),
            (_) => emit(AddUserIdsSuccessState()),
          );
        },
      );
    },
  );
}

}
