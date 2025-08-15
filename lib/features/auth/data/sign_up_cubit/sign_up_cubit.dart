import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepo authRepo;
  SignUpCubit(this.authRepo, ) : super(SignUpInitialState());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController churchNameController = TextEditingController();
  final TextEditingController governmentController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController frontIdController = TextEditingController();
  final TextEditingController backIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  Icon suffixIcon = const Icon(Icons.visibility);
  bool isObscured = true;
  void changePasswordVisibility() {
    isObscured = !isObscured;
    suffixIcon = isObscured
        ? const Icon(Icons.visibility)
        : const Icon(Icons.visibility_off);
    emit(SingUpChangePasswordVisibility());
  }

  Future<void> signUp() async {
    emit(SignUpLoadingState());
    final result = await authRepo.signUp(
      email: emailController.text,
      password: passwordController.text,
      firstName: firstNameController.text,
      lastName: secondNameController.text,
      phone: phoneNumberController.text,
      churchName: churchNameController.text,
      government: governmentController.text,
    );
    result.fold(
      (failure) {
        emit(SignUpFailureState(errorMessage: failure.message));
      },
      (user) {
        emit(SignUpSuccessState(userModel: user));
      },
    );
  }

  Future<void> deleteUserData(String uId) async {
    await authRepo.deleteUserData(uId);
    
  }

  Future<void> completeGoogleSignUp({required String userId}) async {
    emit(SignUpLoadingState());

    try {
      // Upload front ID
   

      // Create completed user model
      final userModel = UserModel(
        id: userId,
        firstName: firstNameController.text,
        lastName: secondNameController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        churchName: churchNameController.text,
        government: governmentController.text,
        
        isApproved: false,
        favorites: [],
      );

      // Save user to Firestore and local storage
      final result = await authRepo.completeGoogleSignUp(userModel: userModel);
      result.fold(
        (failure) => emit(SignUpFailureState(errorMessage: failure.message)),
        (user) => emit(SignUpSuccessState(userModel: user)),
      );
    } catch (e) {
      emit(SignUpFailureState(errorMessage: e.toString()));
    }
  }
}
