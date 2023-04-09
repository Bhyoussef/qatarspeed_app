import 'package:dio/dio.dart';
import 'package:qatar_speed/models/file.dart';
import 'package:qatar_speed/models/poll.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/extensions.dart';

class CreatePostModel {
  int id;
  String? title;
  String privacy;
  bool commentStatus;
  List<FileModel>? media;
  List<PollModel>? polls;
  int? groupId;
  PostModel? originalPost;

  CreatePostModel(
      {this.title,
      this.privacy = 'Everyone',
      this.commentStatus = true,
      this.media,
      this.polls,
      int? id,
      this.originalPost,
      this.groupId}): id = id ?? -1;

  factory CreatePostModel.fromJson(Map<String, dynamic> json) {
    return CreatePostModel(
      id: int.parse(json["id"].toString()),
      title: json["title"],
      privacy: json["privacy"],
      commentStatus: json["comment_status"].toLowerCase() == 'Allowed',
      media: json.containsKey('files')
          ? List.of(json["files"]).map((i) => FileModel.fromJson(i)).toList()
          : null,
      polls: json.containsKey('polls')
          ? List.of(json.get("polls")).map((i) => PollModel.fromJson(json["polls"])).toList()
          : null,
      groupId: int.tryParse(json["groupId"].toString()),
    );
  }

  Future<FormData> toRequest({bool update = false}) async {
    final data = <String, dynamic>{
      'title': title,
      'privacy': privacy,
      'comment_status': '${commentStatus ? '' : 'Not '}Allowed',
    };

    if (update) {
      data['_method'] = 'PATCH';
    }

    if (groupId != null) {
      data['group_id'] = groupId;
    }

    media?.removeWhere((element) => element.file.isEmpty);
    polls?.removeWhere((element) => element.text.isEmpty);

    final formData = FormData.fromMap(data);
    if (media != null && (media?.isNotEmpty ?? false)) {
      for (var img in media!) {
          if (!img.file.startsWith('http')) {
            formData.files
                .add(MapEntry('images[]', await MultipartFile.fromFile(img.file)));
          }
      }
    }

    if (polls != null && (polls?.isNotEmpty ?? false)) {
      for (PollModel element in polls!) {
        formData.fields.add(MapEntry('poll_answers[]', element.text));
      }
    }

    return formData;
  }
}
