import 'package:qatar_speed/models/message.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/res.dart';

class ConversationModel {
  late int id;
  UserModel user;
  List<MessageModel>? messages;
  late int unread;
  Map<String, dynamic>? message;
  bool delete = false;
  late DateTime createdAt;


  ConversationModel({required this.id, required this.user, this.messages, this.unread = 0, this.message}):
  createdAt = (message?.containsKey('created_at') ?? false) && message!['created_at'] != null ? DateTime.parse(message!['created_at']) : DateTime.now();

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: int.parse(json["id"].toString()),
      user: UserModel(
        id: -1,
          username: json['username'],
          firstName: json['first_name'],
          lastName: json['last_name'],
          name: ((json['first_name']??'') + ' ' + (json['last_name']??'')).toString() == ' ' ? 'User' : ((json['first_name']??'') + ' ' + (json['last_name']??'')),
          photo: json['image'].toString().startsWith('http')
              ? json['image']
              : Res.baseUrl + json['image']),
      messages: json.containsKey("messages") ? List.of(json["messages"])
          .map((i) => MessageModel.fromJson(i))
          .toList() : [],
      unread: int.tryParse(json.get('unread').toString()) ?? 0,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": user..username,
      "first_name": user..firstName,
      "last_name": user..lastName,
      "image": user..photo,
      "messages": messages?.map((e) => e.toJson()).toList(),
      "unread": unread,
      "message": message,
    };
  }
}
