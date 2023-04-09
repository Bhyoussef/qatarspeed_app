import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class OtherSettingsScreen extends StatefulWidget {
  const OtherSettingsScreen({Key? key}) : super(key: key);

  @override
  createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherSettingsScreen>
    with RouteAware, RouteObserverMixin {
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings_applications_sharp,
                  size: Res.isPhone ? 50.0 : 60.0,
                ),
                Text(
                  'Followers - Other settings',
                  style: TextStyle(
                      fontFamily: 'arial', fontSize: Res.isPhone ? 16.0 : 19.0),
                ),
              ],
            ),
            const SizedBox(
              height: 40.0,
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Hide followers'),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Hide following'),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            const Divider(),
            /*ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark mode'),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            const Divider(),*/
            ListTile(
              leading: const Icon(Icons.access_time_filled_sharp),
              title: const Text('Set date and time'),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
          ],
        ),
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
