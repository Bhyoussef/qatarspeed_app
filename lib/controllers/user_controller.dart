import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/auth.dart';

class UserController extends GetxController {
  late UserModel user;
  late Box _box;

  UserModel? get getUser => user;

  Future<void> setUser(UserModel user) async {
    this.user = user;
    update();
    await _box.clear();
    await _box.add(user.toJson());
  }

  @override
  void onInit(){
    _box = Hive.box('user');
    super.onInit();
  }


  Future<UserModel?> getLoggedUser() async {
    try {
      user = UserModel.fromJson(Map.from(_box.values.first));
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    Res.token = '';
    await _box.clear();
  }

  Future<String?> updatePasswd({required String old, required String passwd}) async {
    return await AuthWebService().updatePasswd(old, passwd);
  }
}