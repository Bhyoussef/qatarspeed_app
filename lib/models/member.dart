import 'package:qatar_speed/models/user.dart';

class MemberModel {
  bool? isFollowing;
  bool? isOnline;
  int? id;
  String? userId;
  String? groupId;
  String? active;
  String? createdAt;
  String? updatedAt;
  UserModel? user;

  MemberModel(
      {this.id,
      this.userId,
      this.groupId,
      this.active,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.isFollowing,
      this.isOnline});

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      active: json['active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "group_id": groupId,
      "active": active,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "user": user?.toJson(),
    };
  }
}
