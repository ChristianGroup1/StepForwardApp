import 'dart:convert';

import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/auth/data/models/user_model.dart';



UserModel getUserData() {
  var userEntity = UserModel.fromJson(
      jsonDecode(CacheHelper.getData(key: kSaveUserDataKey)));
  return userEntity;
}



