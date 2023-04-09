import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:qatar_speed/models/comment.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/res.dart';

class ProductModel {
  late int id;
  double? price;
  String? location;
  String? title;
  String? description;
  UserModel? user;
  DateTime? createdAt;
  List<String> photos;
  List<CommentModel> comments;
  String? manifacturer;
  String? model;
  String? phone;
  String? mileage;
  int? year;
  int? categoryId;
  String? email;

  ProductModel(
      {this.id = -1,
      this.price,
      this.location,
      this.description,
      this.user,
      List<String>? photos,
      this.createdAt,
      this.title,
        List<CommentModel>? comments,
      this.manifacturer,
      this.model,
      this.phone,
      this.mileage,
      this.year,
        this.email,
      this.categoryId})
  : photos = photos ?? [],
  comments = comments ?? [];

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse(json["id"].toString()) ?? -1,
      price: double.tryParse(json["price"].toString()),
      phone: json['phone'],
      mileage: json['mileage'],
      manifacturer: json['maker'],
      model: json['model'],
      location: json.get("location"),
      title: json['title'],
      description: json["description"],
      user: UserModel.fromJson(json["user"]),
      createdAt: DateTime.tryParse(json["created_at"]),
      photos: List.of(json["images"] ?? [])
          .map((photo) => photo['image'].toString().startsWith('http')
              ? photo['image'].toString()
              : '${Res.baseUrl}${photo['image']}')
          .toList(),
      comments: json.get('comments') != null
          ? List.of(json["comments"])
              .map((comment) => CommentModel.fromJson(comment))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "price": price,
      "location": location,
      "description": description,
      "user": user?.toJson(),
      "title": title,
      "createdAt": createdAt?.toIso8601String(),
      "images": jsonEncode(photos),
      "comments": comments.map((e) => e.toJson()).toList(),
    };
  }

  Future<FormData> toRequest() async {
    final data = {
      'category_id': categoryId,
      'title': title,
      'maker': manifacturer,
      'model': model,
      'mileage': mileage,
      'price': price,
      'description': description,
      'phone': phone,
      'email': email,
    };


    final formData = FormData.fromMap(data);
    for (String photo in photos) {
      formData.files.add(MapEntry('images[]', await MultipartFile.fromFile(photo)));
    }

    return formData;
  }
}
