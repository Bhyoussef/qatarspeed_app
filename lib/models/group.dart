import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/res.dart';

import 'member.dart';

class GroupModel {
  int? id;
  String? name;
  String? description;
  String? image;
  String? cover;
  String? about;
  String? privacy;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<MemberModel> members;
  List<PostModel> posts;
  late bool joined;

  GroupModel(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.cover,
      this.about,
      this.privacy,
      this.status,
      this.createdAt,
      this.updatedAt,
        List<MemberModel>? members,
        List<PostModel>? posts,
      this.joined = false})
  : members = members ?? [],
  posts = posts ?? [];

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'].toString().startsWith('http')
          ? json['image']
          : Res.baseUrl + json['image'],
      cover: json.get('cover').toString().startsWith('http')
          ? json.get('cover')
          : Res.baseUrl + json.get('cover').toString(),
      about: json['about'],
      privacy: json['privacy'],
      status: json['status'],
      createdAt: DateTime.tryParse(json.get('created_at') ?? ''),
      updatedAt: DateTime.tryParse(json.get('updated_at') ?? ''),
      members: List.of(json.get('members') ?? [])
          .map((i) => MemberModel.fromJson(i))
          .toList(),
      joined: json.containsKey('is_joined')
          ? (int.tryParse(json['is_joined'].toString()) ?? 0) > 0
          : json.containsKey('is_joined_count')
              ? (int.tryParse(json['is_joined_count'].toString()) ?? 0) > 0
              : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "image": image,
      "cover": cover,
      "about": about,
      "privacy": privacy,
      "status": status,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "members": members.map((e) => e.toJson()).toList(),
      "is_joined_count": joined ? 1 : 0,
    };
  }
}
