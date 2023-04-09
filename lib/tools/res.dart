import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:get/get.dart';
import 'package:mime_type/mime_type.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/splash_screen.dart';
import 'package:qatar_speed/tools/services/auth.dart';

enum ChatScreenLevel { none, list, conversation }

class Res {
  static final showAppBar = true.obs;
  static String? firebaseToken;
  static final isHome = true.obs;
  static const baseUrl = 'http://beta-website.bunyan.qa/';
  static const apiUrl = '${baseUrl}api/';
  static String token = '';
  static final gotMessages = false.obs;
  static late StreamSubscription<bool> keyboardEventSubscription;
  static ChatScreenLevel chatScreenLevel = ChatScreenLevel.none;

  //static UserModel? user;
  static RxList<Widget> appBarActions = <Widget>[].obs;
  static late BuildContext baseContext;
  static Rx<ScrollController> scrollController = ScrollController().obs;
  static final showBottomBar = true.obs;
  static bool isPhone = Device.get().isPhone;
  static Rx<Widget?> titleWidget = Rx<Widget?>(null);
  static const moderatorColor = Color(0xff005DFF);
  static const vipColor = Color(0xff8800FF);

  static bool? isVideo(String? media) {
    return mime(media?.split('/').last)?.contains('video');
  }

  static void initSystemOverlays() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      systemNavigationBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  static Future<void> logout() async {
    await AuthWebService().logout();
    await Get.find<UserController>().clearUser();
    //await Get.deleteAll(force: true);
    //Get.find<HomeController>().close();
    try {
      Navigator.pushAndRemoveUntil(
          baseContext,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false);
    } catch (_){}
  }
}
