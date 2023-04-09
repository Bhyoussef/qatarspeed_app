import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';

class CommentModel {
  int? id;
  String? comment;
  UserModel? user;
  DateTime? createdAt;
  String? media;
  List<CommentModel> comments;
  bool isLiked;
  int? parentId;

  bool get isMine => user?.id == Get.find<UserController>().user.id;

  CommentModel(
      {this.id,
      this.comment,
      this.user,
      this.createdAt,
      List<CommentModel>? comments,
        this.isLiked = false,
        this.parentId,
      this.media})
      : comments = comments ?? [];

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: int.parse(json["id"].toString()),
      comment: json["text"],
      user: json.containsKey("user") ? UserModel.fromJson(json["user"]) : null,
      createdAt: DateTime.tryParse(json["created_at"] ?? ''),
      media: (json.containsKey('file') && json['file'] != null)
          ? json['file'].toString().startsWith('http')
              ? json['file']
              : '${Res.baseUrl}${json['file']}'
          : null,
      comments: (!json.containsKey('comments') || json['comments'] == null)
          ? []
          : List.of(json['comments'])
              .map((e) => CommentModel.fromJson(e))
              .toList(),
      isLiked: json.containsKey('is_liked_count') ? int.parse(json['is_liked_count'].toString()) > 0 : false,
        parentId: int.parse(json['parent_id'].toString())
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "comment": comment,
      "user": user?.toJson(),
      "file": media,
      "created_at": createdAt?.toIso8601String(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'is_liked_count': isLiked ? 1 : 0,
      "parent_id": parentId,
    };
  }
}
