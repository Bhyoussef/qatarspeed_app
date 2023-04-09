import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:qatar_speed/models/conversation.dart';
import 'package:qatar_speed/models/message.dart';
import 'package:qatar_speed/tools/services/base.dart';

class ChatWebService extends BaseWebService {
  
  Future<Map<String, List<ConversationModel>>> getConversations() async {
    final response = (await dio.get('conversations')).data;

    final map = <String, List<ConversationModel>>{};
    map['conversations'] = List.of(response['conversations']).map((e) => ConversationModel.fromJson(e)).toList();
    map['requests'] = List.of(response['requests']).map((e) => ConversationModel.fromJson(e)).toList();
    return map;
  }
  
  Future<List<MessageModel>> getMessages(ConversationModel conversation, {int page = 0}) async {
    final data = {
      'page': page,
    };
    final response = (await dio.post('get-chat/${conversation.id}', data: data)).data;
    conversation.user.id = response['user']['id'];
    debugPrint('got messages');
    return List.of(response['chat']).map((e) => MessageModel.fromJson(e)).toList().reversed.toList();
  }

  Future<MessageModel> sendMessage({required MessageModel message, required int toId}) async {
    Map<String, dynamic> data = {
      'to_id': toId,
    };
    if (message.media != null) {
      data['image'] = await MultipartFile.fromFile('${message.media}');
    } else {
      data['text'] = message.text;
    }

    final formData = FormData.fromMap(data);

    final response = (await dio.post('message', data: formData)).data;
    return MessageModel.fromJson(Map.of(response)['message']);
  }

  Future<void> deleteMessage(MessageModel message) async {
    await dio.delete('delete-message/${message.id}');
  }

  Future<MessageModel> getMessage(int id) async {
    final response = (await dio.get('get-message-byid/$id')).data;
    return MessageModel.fromJson(response['message']);
  }

  Future deleteConversation(int id) async {
    return (await dio.delete('delete-chat/$id')).data;
  }

  Future<void> accept(int id) async {
    await dio.post('accept-chat-request/$id');
  }
}