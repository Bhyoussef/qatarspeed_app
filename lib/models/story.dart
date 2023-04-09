import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/res.dart';

class StoryModel {
  late int id;
  String? title;
  String? description;
  String? link;
  DateTime? createdAt;
  int? duration;



  StoryModel({required this.id,this.title,this.description,this.link,this.createdAt, this.duration});

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      link: json['file'].toString().startsWith('http') ? json['file'] : Res.baseUrl + json['file'],
      createdAt: DateTime.tryParse(json.get('created_at')??''),
      duration: int.tryParse(json.get('duration').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "file": link,
      "created_at": createdAt,
    };
  }


}