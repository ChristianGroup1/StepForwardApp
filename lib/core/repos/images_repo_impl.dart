import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/core/repos/image_repo.dart';
import 'package:stepforward/core/services/storage_service.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';


class ImagesRepoImpl extends ImagesRepo{
  final StorageService storageService;

  ImagesRepoImpl({required this.storageService});
  @override
  Future<Either<Failure, String>> uploadImage({required File image}) async{
   try {
  String imageUrl=await storageService.uploadFile(image, BackendEndpoints.images);
  return Right(imageUrl);
}  catch (e) {
  return left(CustomFailure(message: 'حدث خطأ اثناء اضافة الصورة'));
}
  }
  
}