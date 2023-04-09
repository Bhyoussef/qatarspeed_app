
import '../tools/res.dart';

class FileModel {
  int id;
  int postId;
  String file;

  FileModel({int? id, int? postId, String? file})
      : id = id ?? -1,
        postId = postId ?? -1,
        file = file ?? '';

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: int.parse(json["id"].toString()),
      postId: int.parse(json["post_id"].toString()),
      file: json["file"].toString().startsWith('http')
        ? json['file'].toString()
        : Res.baseUrl + json['file'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "post_id": postId,
      "file": file,
    };
  }
}
