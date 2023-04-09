import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/profile/settings/screens/blocked_users_settings_screen.dart';
import 'package:qatar_speed/ui/profile/settings/screens/messages_settings_screen.dart';
import 'package:qatar_speed/ui/profile/settings/screens/notifs_settings_screen.dart';
import 'package:qatar_speed/ui/profile/settings/screens/other_settings_screen.dart';
import 'package:qatar_speed/ui/profile/settings/screens/passwd_settings_screen.dart';
import 'package:qatar_speed/ui/profile/settings/screens/saved_posts_settings_screen.dart';
import 'package:qatar_speed/ui/profile/settings/screens/user_info_settings_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with RouteAware, RouteObserverMixin {
  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.scrollController.value = ScrollController();
      Res.appBarActions.value = [
        Container(),
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
      body: ListView(
        children: [
          ListTile(
            onTap: () => Get.to(() => const UserInfoSettingsScrenn()),
            leading: const Icon(Icons.person),
            title: const Text('Personal and account information'),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          ListTile(
            onTap: () => Get.to(() => const PasswdSettingsScrenn()),
            leading: const Icon(Icons.lock),
            title: const Text('Password and security'),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          ListTile(
            onTap: () => Get.to(const NotifsSettingsScrenn()),
            leading: const Icon(Icons.notifications_active),
            title: const Text('Notifications system'),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          ListTile(
            onTap: () => Get.to((() => const MessagesSettingsScreen())),
            leading: const Icon(Icons.email),
            title: const Text('Messages & Stories settings'),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          ListTile(
            onTap: () => Get.to(() => const SavedPostsSettingsScreen()),
            leading: const Icon(Icons.bookmark),
            title: const Text('Manage saved posts'),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          ListTile(
            onTap: () => Get.to(() => const BlockedUsersSettingsScreen()),
            leading: const Icon(Icons.block),
            title: const Text('Blocked users'),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          ListTile(
            onTap: () => Get.to(() => const OtherSettingsScreen()),
            leading: const Icon(Icons.settings_applications_sharp),
            title: const Text('Followers - other settings'),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          const ListTile(
            onTap: Res.logout,
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


}
