import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        final TextEditingController updatedGovernmentController =TextEditingController();

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
      government: updatedGovernmentController.text,
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
            government: updatedGovernmentController.text,
          ),
        );
        emit(UpdateUserProfileSuccessState());
      },
    );
  }

 Future<User> getCurrentUser() async {
    return await authRepo.getCurrentUser();
  }


  void userMakeChanges() {
    hasChanges = true;
    emit(UserMakeChangesInProfile());
  }

    Future<void> signOut() async {
   
    await authRepo.signOut();
  }
    Future<bool> reauthenticateUser(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      return true; // ✅ Authentication successful
    } catch (e) {
      return false; // ❌ Authentication failed
    }
  }
 Future<void> deleteAccount({required String uId, String? password}) async {
    try {
      if (password != null) {
        bool isAuthenticated = await reauthenticateUser(password);
        if (!isAuthenticated) {
          emit(DeleteAccountFailureState(errorMessage: "Reauthentication failed"));
          return;
        }
      }

      var result = await authRepo.deleteAccount(uId: uId,password: password);
      result.fold(
        (failure) {
          emit(DeleteAccountFailureState(errorMessage: failure.message));
        },
        (deleted) => emit(DeleteAccountSuccessState()),
      );
    } catch (e) {
      emit(DeleteAccountFailureState(errorMessage: e.toString()));
    }
  }

}
