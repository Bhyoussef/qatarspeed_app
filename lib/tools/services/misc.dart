import 'dart:io';

import 'package:dio/dio.dart';
import 'package:qatar_speed/models/notification.dart';
import 'package:qatar_speed/models/search.dart';
import 'package:qatar_speed/tools/services/base.dart';

class MiscWsebService extends BaseWebService {
  Future<Map<String, dynamic>> getHomeData() async {
    final response = (await dio.get('index')).data;
    return response;
  }

  Future<void> createStory(File file) async {
    final formData = FormData();
    formData.files
        .add(MapEntry('file', await MultipartFile.fromFile(file.path)));
    await dio.post('story', data: formData);
  }

  Future<SearchModel> search(String keyword) async {
    final response = (await dio.post('search', data: {'search': keyword})).data;
    return SearchModel.fromJson(response);
  }

  deleteStory(int id) async {
    await dio.post('delete-story/$id');
  }

  Future<bool> toggleGroupJoin(int id) async {
    final response =
        (await dio.post('join-group/$id')).data['message'].toString();
    return response.toLowerCase().contains('joined');
  }

  Future<List<Map<String, dynamic>>> getPages() async {
    return List.of((await dio.get('pages')).data['pages'])
        .cast<Map<String, dynamic>>();
  }

  Future<Map<String, List<NotificationModel>>> getNotifications() async {
    final response = (await dio.get('notifications')).data['notifications'];
    final notifs =
        List.of(response).map((e) => NotificationModel.fromJson(e)).toList();
    Map<String, List<NotificationModel>> notifications = {};
    while (notifs.isNotEmpty) {
      if (!notifications.containsKey(notifs.first.type)) {
        notifications[notifs.first.type] = [];
      }
      notifications[notifs.first.type]!
          .addAll(notifs.where((element) => element.type == notifs.first.type));
      notifs.removeWhere((element) => element.type == notifs.first.type);
    }

    return notifications;
  }

  Future<void> readNotification(NotificationModel notification) async {
    await dio.post('read-notification/${notification.id}');
  }
}
