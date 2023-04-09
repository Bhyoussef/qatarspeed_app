import 'package:qatar_speed/models/user.dart';

class FriendsModel {
  late List<UserModel> following;
  late List<UserModel> followers;

  FriendsModel({List<UserModel>? following, List<UserModel>? followers})
      : following = following ?? [],
        followers = followers ?? [];

  factory FriendsModel.fromJson(Map<String, dynamic> json) {
    return FriendsModel(
      following: List.of(json["following"])
          .map((i) => UserModel.fromJson(i)..following = true)
          .toList(),
      followers: List.of(json["followers"])
          .map((i) => UserModel.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "following": following.map((e) => e.toJson()).toList(),
      "followers": followers.map((e) => e.toJson()).toList(),
    };
  }
}
