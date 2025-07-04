import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:stepforward/core/errors/custom_exceptions.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/services/database_service.dart';
import 'package:stepforward/core/services/firebase_auth_service.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';

class AuthRepoImpl extends AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final DatabaseService databaseService;

  AuthRepoImpl({
    required this.firebaseAuthService,
    required this.databaseService,
  });
  @override
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
  }) async {
    try {
      final user = await firebaseAuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      var userModel = UserModel(
        id: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone,
        churchName: churchName,
        government: government,
        frontId: frontId,
        backId: backId,
      );
      await addUserData(userModel: userModel);
      await getUserData(id: user.uid);
      await saveUserData(userModel: userModel);
      return Right(userModel);
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future addUserData({required UserModel userModel}) async {
    await databaseService.addData(
      uId: userModel.id,
      path: BackendEndpoints.addUserData,
      data: userModel.toJson(),
    );
  }

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      var user = await firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      var userData = await getUserData(id: user.uid);
      await saveUserData(userModel: userData);
      return Right(userData);
    } catch (e) {
      return left(CustomFailure(message: e.toString()));
    }
  }

  @override
  Future<UserModel> getUserData({required String id}) async {
    var userData = await databaseService.getData(
      path: BackendEndpoints.getUserData,
      documentId: id,
    );
    var userEntity = UserModel.fromJson(userData);
    return userEntity;
  }

  @override
  Future saveUserData({required UserModel userModel}) async {
    var userData = jsonEncode(userModel.toJson());
    await CacheHelper.saveData(key: kSaveUserDataKey, value: userData);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await firebaseAuthService.sendEmailToResetPassword(email: email);
      return right(null);
    } on CustomException catch (e) {
      return left(CustomFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserData({
    required String uId,
    required String firstName,
    required String lastName,
    required String churchName,
    required String phoneNumber,
  }) async {
    try {
      // Update user data in the database
      await databaseService.updateData(
        path: BackendEndpoints.addUserData,
        documentId: uId,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'churchName': churchName,
          'phoneNumber': phoneNumber,
        },
      );

      // Save updated user data to cache

      return const Right(null);
    } on CustomException catch (e) {
      return Left(CustomFailure(message: e.message));
    } catch (e) {
      return Left(
        CustomFailure(
          message: 'An unexpected error occurred while updating user data.',
        ),
      );
    }
  }



}
