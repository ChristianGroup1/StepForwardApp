import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:stepforward/core/repos/image_repo.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepo authRepo;
  final ImagesRepo imagesRepo;
  SignUpCubit(this.authRepo, this.imagesRepo) : super(SignUpInitialState());
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
  File? frontId;
  File? backId;
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
    final result = await imagesRepo.uploadImage(image: frontId!);
    result.fold(
      (failure) {
        emit(SignUpFailureState(errorMessage: failure.message));
      },
      (imageUrl) async {
        frontIdController.text = imageUrl;
        final result = await imagesRepo.uploadImage(image: backId!);
        result.fold(
          (failure) {
            emit(SignUpFailureState(errorMessage: failure.message));
          },
          (imageUrl) async {
            backIdController.text = imageUrl;
            final result = await authRepo.signUp(
              email: emailController.text,
              password: passwordController.text,
              firstName: firstNameController.text,
              lastName: secondNameController.text,
              phone: phoneNumberController.text,
              churchName: churchNameController.text,
              government: governmentController.text,
              frontId: frontIdController.text,
              backId: backIdController.text,
            );
            result.fold(
              (failure) {
                emit(SignUpFailureState(errorMessage: failure.message));
              },
              (user) {
                emit(SignUpSuccessState(userModel: user));
              },
            );
          },
        );
      },
    );
  }
}
