import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/settings_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class NotifsSettingsScrenn extends StatefulWidget {
  const NotifsSettingsScrenn({Key? key}) : super(key: key);

  @override
  createState() => _NotifsScreenState();
}

class _NotifsScreenState extends State<NotifsSettingsScrenn>
    with RouteAware, RouteObserverMixin {
  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  void didPush() {
    super.didPush();
    _initAppbar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: GetBuilder<SettingController>(
          builder: (controller) => ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: Res.isPhone ? 50.0 : 60.0,
                  ),
                  Text(
                    'Notifications',
                    style: TextStyle(
                        fontFamily: 'arial',
                        fontSize: Res.isPhone ? 16.0 : 19.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('New posts in the group'),
                onTap: () {
                  controller.notifications.groupPost =
                      !controller.notifications.groupPost;
                  controller.update();
                },
                trailing: Switch(
                    value: controller.notifications.groupPost,
                    onChanged: (val) {
                      controller.notifications.groupPost = val;
                      controller.update();
                    }),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('New comments to your post'),
                onTap: () {
                  controller.notifications.commentPost =
                      !controller.notifications.commentPost;
                  controller.update();
                },
                trailing: Switch(
                    value: controller.notifications.commentPost,
                    onChanged: (val) {
                      controller.notifications.commentPost = val;
                      controller.update();
                    }),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('New comment reply'),
                onTap: () {
                  controller.notifications.replyComment =
                      !controller.notifications.replyComment;
                  controller.update();
                },
                trailing: Switch(
                    value: controller.notifications.replyComment,
                    onChanged: (val) {
                      controller.notifications.replyComment = val;
                      controller.update();
                    }),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Liked post'),
                onTap: () {
                  controller.notifications.likePost =
                      !controller.notifications.likePost;
                  controller.update();
                },
                trailing: Switch(
                    value: controller.notifications.likePost,
                    onChanged: (val) {
                      controller.notifications.likePost = val;
                      controller.update();
                    }),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Liked comment'),
                onTap: () {
                  controller.notifications.likeComment =
                      !controller.notifications.likeComment;
                  controller.update();
                },
                trailing: Switch(
                    value: controller.notifications.likeComment,
                    onChanged: (val) {
                      controller.notifications.likeComment = val;
                      controller.update();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doneBtn() {
    final controller = Get.find<SettingController>();
    return TextButton(
        onPressed: controller.isRequesting
            ? null
            : () {
                controller.updateSettings().then((value) {
                  _initAppbar();
                  Get.back();
                });
                _initAppbar();
              },
        child: const Text('Done'));
  }
}
