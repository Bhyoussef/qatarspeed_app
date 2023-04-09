import 'package:qatar_speed/tools/res.dart';

enum SentStatus {
  sent,
  sending,
  failed,
  deleted,
}

class MessageModel {
  late int id;
  late int fromId;
  String? text;
  String? media;
  bool? seen;
  DateTime? createdAt;
  int? deleteFrom;
  int? deleteTo;
  late SentStatus status;
  late bool selected;


  MessageModel(
      {required this.id, required this.fromId, this.text, this.media, this.seen, this.createdAt, this.status = SentStatus.sent, this.deleteFrom, this.deleteTo, this.selected = false});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: int.parse(json["id"].toString()),
      fromId: int.parse(json["from_id"].toString()),
      text: json.containsKey('text') ? json["text"] : null,
      media: json.containsKey('image') ? json["image"].toString().startsWith(('http')) ? json["image"] : json["image"].toString().isNotEmpty ? '${Res.baseUrl}${json["image"]}' : '' : '',
      seen: json["seen"] != null,
      createdAt: DateTime.tryParse(json["created_at"]),
      status: (json['delete_from'] != null || json['delete_to'] != null) ? SentStatus.deleted : SentStatus.sent,
      deleteFrom: int.tryParse(json['delete_from'].toString()),
      deleteTo: int.tryParse(json['delete_to'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "from_id": fromId,
      "text": text,
      "image": media,
      "seen": seen,
      "created_at": createdAt?.toIso8601String(),
      "delete_to": deleteTo,
      "delete_from": deleteFrom,
    };
  }


  void copyTo(MessageModel message) {
    message.text = text;
    message.media = media;
    message.id = id;
    message.fromId = fromId;
    message.seen = seen;
    message.deleteFrom = deleteFrom;
    message.deleteTo = deleteTo;
    message.createdAt = createdAt;
  }

//

}