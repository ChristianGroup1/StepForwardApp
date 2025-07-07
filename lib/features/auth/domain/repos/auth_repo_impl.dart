import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    User? user;
    try {
      user = await firebaseAuthService.signInWithGoogle();

      final isUserExist = await databaseService.checkIfDataExist(
        path: BackendEndpoints.getUserData,
        uId: user.uid,
      );

      if (isUserExist) {
        final existingUser = await getUserData(id: user.uid);
        await saveUserData(userModel: existingUser);
        return Right(existingUser);
      } else {
        // User is signing in with Google for the first time
        final googleUser = UserModel(
          id: user.uid,
          firstName: user.displayName?.split(' ').first ?? '',
          lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
          email: user.email ?? '',
          phoneNumber:  '',
          government: '',
          churchName: '',
          isApproved: false,
          frontId: null,
          backId: null,
          favorites: [],
        );
        
       
        return Right(googleUser);
      }
    } on CustomException catch (e) {
      return Left(CustomFailure(message: e.toString()));
    } catch (e) {
      if (user != null) await firebaseAuthService.deleteUser();
      return Left(CustomFailure(message: 'حدث خطأ ما، حاول مرة اخرى'));
    }
  }

@override
  Future<Either<Failure, UserModel>> completeGoogleSignUp({required UserModel userModel}) async {
  try {
    await databaseService.addData(
      path: BackendEndpoints.addUserData,
      uId: userModel.id,
      data: userModel.toJson(),
    );
    await saveUserData(userModel: userModel);
    return Right(userModel);
  } catch (e) {
    return Left(CustomFailure(message: 'فشل في استكمال تسجيل الدخول: ${e.toString()}'));
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
    required String government
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
          'government': government
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

    @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Sign out the user
      await firebaseAuthService.signOut();

      // Remove cached user data

     await CacheHelper.removeData(key: kSaveUserLocationKey);

      return const Right(null);
    } on CustomException catch (e) {
      return Left(CustomFailure(message: e.message));
    } catch (e) {
      return Left(CustomFailure(
          message: 'An unexpected error occurred while logging out.'));
    }
  }
@override
 Future<User> getCurrentUser() async {
    return await firebaseAuthService.getCurrentUser();
  }
  @override
Future<Either<Failure, void>> deleteAccount({required String uId, String? password}) async {
  try {


    User? user =await getCurrentUser();

    // Re-authenticate user based on provider
    if (user.providerData.any((info) => info.providerId == 'password')) {
      if (password == null || password.isEmpty) {
        return Left(CustomFailure(message: "Password is required for account deletion"));
      }
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } else if (user.providerData.any((info) => info.providerId == 'google.com')) {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return Left(CustomFailure(message: "Google re-authentication failed"));
      }
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
    }

    // ✅ Delete user data from Firestore first
    await databaseService.deleteData(
      path: BackendEndpoints.getUserData,
      uId: uId,
    );

    // ✅ Delete Firebase Auth user
    await firebaseAuthService.deleteUser();

    // ✅ Clear Local Cache
    await CacheHelper.removeData(key: kSaveUserDataKey);
    await CacheHelper.removeData(key: kSaveUserLocationKey);

    return const Right(null);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      return Left(CustomFailure(message: "Incorrect password"));
    } else if (e.code == 'user-mismatch') {
      return Left(CustomFailure(message: "User mismatch. Try signing in again"));
    } else {
      return Left(CustomFailure(message: "Re-authentication failed: ${e.message}"));
    }
  } catch (e) {
    return Left(CustomFailure(message: "Unexpected error: ${e.toString()}"));
  }
}
}
