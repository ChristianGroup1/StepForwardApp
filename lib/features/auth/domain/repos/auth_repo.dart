import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserModel>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String churchName,
    required String government,
    required String frontId,
    required String backId,
  });

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserModel>> signInWithGoogle();
  Future<Either<Failure, UserModel>> completeGoogleSignUp({
    required UserModel userModel,
  });
  Future addUserData({required UserModel userModel});

  Future<UserModel> getUserData({required String id});

  Future saveUserData({required UserModel userModel});
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  Future<Either<Failure, void>> updateUserData({
    required String uId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String churchName,
    required String government
  });
  Future<Either<Failure, void>> signOut();
  Future<User> getCurrentUser();
  Future<Either<Failure, void>> deleteAccount({
    required String uId,
    String? password,
  });
}
