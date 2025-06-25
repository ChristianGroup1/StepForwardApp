import 'package:dartz/dartz.dart';
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
  Future addUserData({required UserModel userModel});

  Future<UserModel> getUserData({required String id});

  Future saveUserData({required UserModel userModel});
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});
}
