
import 'package:get_it/get_it.dart';
import 'package:stepforward/core/repos/image_repo.dart';
import 'package:stepforward/core/repos/images_repo_impl.dart';
import 'package:stepforward/core/services/database_service.dart';
import 'package:stepforward/core/services/fire_storage.dart';
import 'package:stepforward/core/services/firebase_auth_service.dart';
import 'package:stepforward/core/services/firestore_service.dart';
import 'package:stepforward/core/services/storage_service.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo_impl.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<StorageService>(FireStorageService());
  getIt.registerSingleton<DatabaseService>(FireStoreService());
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());

  getIt.registerSingleton<AuthRepo>(AuthRepoImpl(
    databaseService: getIt.get<DatabaseService>(),
    firebaseAuthService: getIt.get<FirebaseAuthService>(),
  ));
  getIt.registerSingleton<ImagesRepo>(ImagesRepoImpl(
    storageService: getIt<StorageService>(),
  ));
}
