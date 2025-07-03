import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';

part 'more_state.dart';

class MoreCubit extends Cubit<MoreState> {
  final AuthRepo authRepo;
  final TextEditingController updatedFirstNameController =
      TextEditingController();
  final TextEditingController updatedLastNameController =
      TextEditingController();
  final TextEditingController updatedChurchNameController =
      TextEditingController();
  final TextEditingController updatedPhoneController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool hasChanges = false;
  MoreCubit(this.authRepo) : super(MoreInitial());

  Future<void> updateUserData() async {
    emit(UpdateUserProfileLoadingState());
    var result = await authRepo.updateUserData(
      uId: getUserData().id,
      phoneNumber: updatedPhoneController.text,
      firstName: updatedFirstNameController.text,
      lastName: updatedLastNameController.text,
      churchName: updatedChurchNameController.text,
    );
    result.fold(
      (failure) {
        emit(
          UpdateUserProfileFailureState(
            errorMessage: failure.message,
          ),
        );
      },
      (data) {
        authRepo.saveUserData(
          userModel: UserModel(
            firstName: updatedFirstNameController.text,
            lastName: updatedLastNameController.text,
            phoneNumber: updatedPhoneController.text,
            email: getUserData().email,
            id: getUserData().id,
            churchName: updatedChurchNameController.text,
            government: getUserData().government,
          ),
        );
        emit(UpdateUserProfileSuccessState());
      },
    );
  }

  void userMakeChanges() {
    hasChanges = true;
    emit(UserMakeChangesInProfile());
  }
}
