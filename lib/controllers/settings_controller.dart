import 'dart:async';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qatar_speed/models/message_stories_settings.dart';
import 'package:qatar_speed/models/notification_settings.dart';
import 'package:qatar_speed/tools/services/auth.dart';

class SettingController extends GetxController {
  NotificationSettingsModel? _notifications;
  MessageStoriesSettingsModel? _messageStory;

  NotificationSettingsModel get notifications => _notifications!;
  MessageStoriesSettingsModel get messageStory => _messageStory!;

  late Box _box;

  bool isRequesting = false;

  Future<String> updateSettings() async {
    isRequesting = true;
    final message = await AuthWebService().updateNotifications(notifications);
    await _box.put('notifications', notifications.toJson());
    isRequesting = false;
    return message;
  }

  void setMessageStories(MessageStoriesSettingsModel settings) {
    messageStory.messages = settings.messages;
    messageStory.stories = settings.stories;
    update();
  }

  void updateMessageStoriesSettings() {
    AuthWebService().updateMessageStoriesSettings(messageStory);
    _box.put('messages_stories', messageStory.toJson());
  }

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box('settings');
    if (_box.isNotEmpty && _box.containsKey('notifications')) {
      _notifications = NotificationSettingsModel.fromJson(_box.get('notifications'));
    } else {
      _notifications = NotificationSettingsModel();
    }
    if (_box.isNotEmpty && _box.containsKey('messages_stories')) {
      _messageStory = MessageStoriesSettingsModel.fromJson(_box.get('messages_stories'));
    } else {
      _messageStory = MessageStoriesSettingsModel();
    }
    update();
  }
}
