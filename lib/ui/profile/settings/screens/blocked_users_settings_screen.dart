import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/profile_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/member_widget.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class BlockedUsersSettingsScreen extends StatefulWidget {
  const BlockedUsersSettingsScreen({Key? key}) : super(key: key);

  @override
  createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<BlockedUsersSettingsScreen>
    with RouteAware, RouteObserverMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<ProfileController>().getBlockedUsers();
    });
  }

  @override
  void didPopNext() {
    super.didPopNext();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  void didPush() {
    super.didPush();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: GetBuilder<ProfileController>(
            id: 'blocked_users',
            builder: (controller) {
              return ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 30.0),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block,
                        size: Res.isPhone ? 50.0 : 60.0,
                      ),
                      Text(
                        'Blocked users',
                        style: TextStyle(
                            fontFamily: 'arial',
                            fontSize: Res.isPhone ? 16.0 : 19.0),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  if (controller.isLoadingBlockedUsers ||
                      controller.blockedUsers.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: Get.height * .25),
                      child: Center(
                        child: controller.isLoadingBlockedUsers
                            ? const CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black),
                        ) : controller.blockedUsers.isEmpty
                            ? const Text('No blocked users',
                          style: TextStyle(fontSize: 30, color: Colors.grey),)
                        : const SizedBox.shrink(),
                      ),
                    )
                  else
                    ...controller.blockedUsers
                        .map((e) =>
                        MemberWidget(
                           showbutton: true,
                            showPopup: false,
                            member: e,
                            onUserTap: (user) {
                              controller.unblockUser(user!).then((value) {
                                final home = Get.find<HomeController>();
                                home.page = 0;
                                home.canLoadMore = true;
                                home.posts.clear();
                                home.getPosts();
                              });
                            }))
                        .toList()

                ],
              );
            }),
      ),
    );
  }

  Widget _doneBtn() {
    return TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Done'));
  }
}
