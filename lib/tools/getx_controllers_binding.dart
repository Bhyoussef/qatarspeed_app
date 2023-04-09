import 'package:get/get.dart';
import 'package:qatar_speed/controllers/chat_controller.dart';
import 'package:qatar_speed/controllers/create_post_controller.dart';
import 'package:qatar_speed/controllers/friends_controller.dart';
import 'package:qatar_speed/controllers/group_controller.dart';
import 'package:qatar_speed/controllers/comments_controller.dart';
import 'package:qatar_speed/controllers/market_controller.dart';
import 'package:qatar_speed/controllers/settings_controller.dart';
import 'package:qatar_speed/controllers/profile_controller.dart';
import 'package:qatar_speed/controllers/search_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';

class ControllersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => CommentController(), fenix: true);
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => CreatePostController(), fenix: true);
    Get.lazyPut(() => GroupController(), fenix: true,);
    Get.lazyPut(() => MarketController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => SearchController(), fenix: true);
    Get.lazyPut(() => SettingController(), fenix: true);
    Get.lazyPut(() => FriendsController(), fenix: true);
  }

}