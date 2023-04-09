import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/models/user.dart';

class SearchModel {
  late List<UserModel> users;
  late List<PostModel> posts;
  late List<GroupModel> groups;

  SearchModel({required this.users, required this.posts, required this.groups});

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      users: List.of(json["users"])
          .map((i) => UserModel.fromJson(i))
          .toList(),
      posts: List.of(json["posts"])
          .map((i) => PostModel.fromJson(i))
          .toList(),
      groups: List.of(json["groups"])
          .map((i) => GroupModel.fromJson(i))
          .toList(),
    );
  }


  int _length() {
    int ln = 0;
    if (users.isNotEmpty) {
      ln++;
    }
    if (posts.isNotEmpty) {
      ln++;
    }
    if (groups.isNotEmpty) {
      ln++;
    }

    return ln;
  }

  int get length => _length();
//

}