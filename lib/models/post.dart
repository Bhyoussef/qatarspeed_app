import 'package:equatable/equatable.dart';
import 'package:qatar_speed/models/create_post.dart';
import 'package:qatar_speed/models/file.dart';
import 'package:qatar_speed/models/poll.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/extensions.dart';

import 'comment.dart';

// ignore: must_be_immutable
class PostModel extends Equatable {
  int id;
  UserModel? user;
  String? text;
  List<FileModel> media;
  int? commentsNumber;
  int? views;
  int? shares;
  bool? canComment;
  int? likes;
  bool? isLiked;
  DateTime? createdAt;
  int? votedPoll;
  List<CommentModel> comments;
  List<PollModel> polls;
  PostModel? originalPost;
  String? privacy;

  PostModel({
    int? id,
    this.text,
    List<FileModel>? media,
    this.commentsNumber,
    this.views,
    this.shares,
    List<CommentModel>? comments,
    List<PollModel>? polls,
    this.user,
    this.createdAt,
    this.canComment,
    this.isLiked,
    this.likes,
    this.votedPoll,
    this.originalPost,
    this.privacy,
  })  : id = id ?? -1,
        comments = comments ?? [],
        media = media ?? [],
        polls = polls ?? [];

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final usr =
        json.get('user') != null ? UserModel.fromJson(json["user"]) : null;
    final pls = json.containsKey('polls')
        ? List.of(json['polls']).map((e) => PollModel.fromJson(e)).toList()
        : <PollModel>[];

    int? voted;

    List<double> rates = [];

    for (int i = 0; i < pls.length; i++) {
      rates.add(.0);
      rates[i] += pls[i].votes?.length ?? 0;
    }

    for (int i = 0; i < rates.length; i++) {
      if (pls[i].votedPoll ?? false) {
        voted = pls[i].id;
      }
      pls[i].rate = rates[i] / rates.length;
    }

    return PostModel(
      id: int.parse(json["id"].toString()),
      user: usr,
      text: json["title"],
      votedPoll: voted,
      privacy: json['privacy'],
      media: List.of(json["files"])
          .map((i) => FileModel.fromJson(i))
          .toList(),
      commentsNumber: int.tryParse(json['comments_count'].toString()) ?? 0,
      views: int.tryParse(json["views"].toString()),
      shares: int.tryParse(json["post_share"].toString()),
      polls: pls,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      canComment: json['comment_status'].toString() == "Allowed",
      isLiked: (int.tryParse(json['is_liked_count'].toString()) ?? 0) > 0,
      likes: int.tryParse(json['likes_count'].toString()),
      comments: json.containsKey('comments')
          ? List.of(json["comments"]).map((i) {
              return CommentModel.fromJson(i);
            }).toList()
          : [],
      originalPost: json.containsKey('shared_post') &&
              json['shared_post'] is! List<dynamic> &&
              json['shared_post'] != null
          ? PostModel.fromJson(Map.of(json['shared_post']))
          : null,
    );
  }

  CreatePostModel toUpdate() {
    return CreatePostModel(
      id: id,
      originalPost: originalPost,
      media: media,
      title: text,
      commentStatus: canComment ?? true,
      polls: polls.map((e) => e).toList(),
      privacy: privacy ?? 'Everyone',
    );
  }

  @override
  List<Object?> get props => [id];
}
