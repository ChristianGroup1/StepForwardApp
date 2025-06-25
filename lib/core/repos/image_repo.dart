import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:stepforward/core/errors/failures.dart';

abstract class ImagesRepo {
  Future <Either<Failure,String>>uploadImage({required File image});
}