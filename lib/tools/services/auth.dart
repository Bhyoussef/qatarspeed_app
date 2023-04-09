import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qatar_speed/models/message_stories_settings.dart';
import 'package:qatar_speed/models/notification_settings.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/base.dart';

class AuthWebService extends BaseWebService {
  Future<UserModel> login(String email, String password) async {
    final response = (await dio.post('login', data: {
      'email': email,
      'password': password,
      'firebase_token': Res.firebaseToken
    }))
        .data;
    Res.token = response['token'];
    final user = UserModel.fromJson(response['user']);
    return user;
  }

  Future<void> updateProfile(UserModel user) async {
    (await dio.post('updateProfile', data: user.toRequest())).data;
  }

  Future<UserModel> signup(UserModel user) async {
    final response = (await dio.post('register', data: user.toSignup())).data;
    Res.token = response['token'];
    return UserModel.fromJson(response['user']);
  }

  logout() async {
    try {
      await dio.post('logout', data: {'firebase_token': Res.firebaseToken});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<UserModel> getUser(int userId) async {
    final response = (await dio.get('user/$userId')).data;
    return UserModel.fromJson(response['user']);
  }

  Future<String?> updatePasswd(String old, String passwd) async {
    try {
      final response = (await dio.post('updatePassword',
              data: {'old_password': old, 'password': passwd}))
          .data;
      if (!response['message'].toString().contains('successfully')) {
        return response['message'];
      }
    } on DioError catch (e) {
      if (e.response?.data != null) {
        return e.response!.data['message'];
      }

      return 'Something went wrong. Please try again later';
    }
    return null;
  }

  Future<Map<String, dynamic>> updatePhoto(
      String path, bool isProfilePicture) async {
    final formData = FormData();
    formData.files.add(MapEntry(isProfilePicture ? 'image' : 'cover',
        await MultipartFile.fromFile(path)));
    final response = (await dio.post('updateCover', data: formData)).data;
    return response['cover'];
  }

  Future<String> blockUser(int id) async {
    final response = Map.of((await dio.post('block/$id')).data);
    if (response.containsKey('like')) {
      return response['like'];
    }

    return 'User blocked';
  }

  Future<String> updateNotifications(NotificationSettingsModel notification) async {
    final data = notification.toJson();
    final response =
        Map.of((await dio.post('notification-privacy', data: data)).data);
    return response.containsKey('message') && response['message'] != null
        ? response['message']
        : 'Success';
  }

  Future<String> forgotPassword(String email) async {
    final response =
        Map.of((await dio.post('forgotPassword', data: {'email': email})).data);

    if (response.containsKey('message') && response['message'] != null) {
      return response['message'];
    }

    return 'Something went wrong.\nPlease try again later.';
  }

  Future<bool> toggleFollow(int id) async {
    return !(await dio.post('follow-user/$id'))
        .data['message']
        .toString()
        .toLowerCase()
        .contains('unfollow');
  }

  Future<List<UserModel>> getBlockedUsers() async {
    final response = (await dio.get('blocked')).data;
    return List.of(response['blocked'])
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  Future<bool> toggleBlock(UserModel user) async {
    final response = (await dio.post('block/${user.id}')).data;

    return !response['message'].toString().toLowerCase().contains('unblocked');
  }

  Future<void> updateMessageStoriesSettings(MessageStoriesSettingsModel messageStory) async {
    await dio.post('message-story-privacy', data: messageStory.toJson());
  }
}
