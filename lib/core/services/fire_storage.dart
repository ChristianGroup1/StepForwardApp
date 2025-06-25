import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart'as b;
import 'package:stepforward/core/services/storage_service.dart';

class FireStorageService extends StorageService {
  final storageReference=FirebaseStorage.instance.ref();
  @override
  Future<String> uploadFile(File file, String path)async {
    String fileName =b.basename(file.path);
    String extensionName=b.extension(file.path);
   var fileReference= storageReference.child('$path/$fileName.$extensionName');
  
    await fileReference.putFile(file);

    return await fileReference.getDownloadURL();
  }
}