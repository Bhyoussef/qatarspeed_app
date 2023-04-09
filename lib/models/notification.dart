import 'package:qatar_speed/models/user.dart';

class NotificationModel {
  late String id;
  late String type;
  late UserModel user;
  int? postId;
  late String text;
  late DateTime createdAt;
  late bool isRead;

  NotificationModel(
      {required this.id,
      required String type,
      required this.user,
      required this.text,
      this.postId,
      DateTime? createdAt,
      required this.isRead})
      : type = type
            .substring(type.lastIndexOf('\\') + 1)
            .replaceAll('Notification', ''),
        createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"],
      type: json["type"],
      createdAt: DateTime.parse(json['created_at']),
      user: UserModel.fromJson(json["data"][0]['user']),
      postId: Map.of(json["data"][0]).containsKey('post_id')
          ? int.parse(json["data"][0]["post_id"].toString())
          : null,
      text: json['data'][0]['text'],
      isRead: json['read_at'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      'created_at': createdAt.toIso8601String(),
      'read_at': isRead ? true : null,
      "data": [
        {'user': user.toJson(), 'post_id': postId, 'text': text}
      ],
    };
  }
}
