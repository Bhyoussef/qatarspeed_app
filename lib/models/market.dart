import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/res.dart';

class MarketModel {
  late int id;
  String? name;
  String? photo;

  MarketModel({required this.id, this.name, this.photo});

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: int.parse(json["id"].toString()),
      name: json["name"],
      photo: Res.baseUrl + json.get("image"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": photo,
    };
  }

}