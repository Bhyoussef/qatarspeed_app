import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/settings_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class MessagesSettingsScreen extends StatefulWidget {
  const MessagesSettingsScreen({Key? key}) : super(key: key);

  @override
  createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesSettingsScreen>
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
        child: GetBuilder<SettingController>(
          builder: (controller) => ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.email,
                    size: Res.isPhone ? 50.0 : 60.0,
                  ),
                  Text(
                    'Messages settings',
                    style: TextStyle(
                        fontFamily: 'arial',
                        fontSize: Res.isPhone ? 16.0 : 19.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              _param(
                  'Who can message you?',
                  'If selected only users you follow then you will \nreceive request message from other users.',
                  'People I Follow',
                  'Everyone',
                  controller.messageStory.messages, (val) {
                controller.messageStory.messages = val;
                controller.update();
              }),
              const Divider(
                height: 100.0,
              ),
              _param('Who can see my stories?', '', 'People I Follow', 'Everyone',
                  controller.messageStory.stories, (val) {
                controller.messageStory.stories = val;
                controller.update();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doneBtn() {
    return TextButton(
        onPressed: () {
          Get.find<SettingController>().updateMessageStoriesSettings();
          Get.back();
        },
        child: const Text('Done'));
  }

  Widget _param(String title, String desc, String firstVal, String secondVal,
      String val, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 16.0,
                color: Color(0xFF5B5B5B),
              ),
            ),
          ],
        ),
        Text(
          desc,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 14.0,
            color: Color(0xFF5B5B5B),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Divider(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 30.0,
            ),
            const Text(
              'Only users you follow',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16.0,
                color: Color(0xFF5B5B5B),
              ),
            ),
            const Spacer(
              flex: 3,
            ),
            Radio(
              groupValue: val,
              value: firstVal,
              onChanged: (String? value) {
                onChanged(value!);
              },
            ),
            const SizedBox(
              width: 30.0,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 30.0,
            ),
            const Text(
              'Every users',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16.0,
                color: Color(0xFF5B5B5B),
              ),
            ),
            const Spacer(
              flex: 3,
            ),
            Radio(
              groupValue: val,
              value: secondVal,
              onChanged: (String? value) {
                onChanged(value!);
              },
            ),
            const SizedBox(
              width: 30.0,
            ),
          ],
        ),
      ],
    );
  }
}
