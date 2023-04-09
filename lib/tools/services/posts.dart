import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/comment.dart';
import 'package:qatar_speed/models/create_post.dart';
import 'package:qatar_speed/models/file.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/services/base.dart';

class PostsWebService extends BaseWebService {
  Future<List<PostModel>> getPosts(
      {int page = 0, int? userId, int? groupId, int? postId}) async {
    final data = {'page': page};
    if (userId != null) {
      data['user_id'] = userId;
    }
    if (groupId != null) {
      data['group_id'] = groupId;
    }
    if (postId != null) {
      data['post_id'] = postId;
    }
    final response = (await dio.get('posts', queryParameters: data)).data;
    return List.of(response['posts'])
        .map((e) => PostModel.fromJson(e))
        .toList();
  }

  Future<CommentModel> addComment(
      {required int postId, String? text, String? media, int? parentId}) async {
    final data = <String, dynamic>{
      'post_id': postId,
    };

    if (parentId != null) {
      data['comment_id'] = parentId;
    }

    if (text != null) {
      data['text'] = text;
    }
    if (media != null) {
      data['file'] = await MultipartFile.fromFile(media);
    }

    final formData = FormData.fromMap(data);

    final response = (await dio.post('comment', data: formData)).data;

    final comment = CommentModel.fromJson(response['comment']);
    comment.user = Get.find<UserController>().user;

    return comment;
  }

  Future<void> togglePostLike(PostModel post) async {
    final data = {
      "post_id": post.id,
    };

    await dio.post('like', data: data);
    return;
  }

  Future<void> deleteComment(CommentModel comment) async {
    await dio.delete('comment/${comment.id}');
  }

  Future<void> toggleCommentLike(CommentModel comment) async {
    final response = (await dio.post('like-comment/${comment.id}')).data;
    debugPrint('like comment   $response');
    return;
  }

  Future<PostModel> createPost(CreatePostModel post) async {
    final response =
        (await dio.post('posts', data: await post.toRequest())).data;

    return PostModel.fromJson(response['post']);
  }

  Future<List<PostModel>> getGroupPosts(
      {required int groupId, int page = 0}) async {
    final response = (await dio
            .get('posts', queryParameters: {'group_id': groupId, 'page': page}))
        .data;
    return List.of(response['posts'])
        .map((e) => PostModel.fromJson(e))
        .toList();
  }

  Future<String> reportPost(int id, String raison) async {
    final data = {
      'post_id': id,
      'message': raison,
    };
    final response = Map.of((await dio.post('report-post', data: data)).data);
    if (response.containsKey('message')) {
      return response['message'];
    }
    return 'Thank you for your feedback!';
  }

  Future<void> votePoll(int id, int postId) async {
    final data = {
      'post_id': postId,
      'poll_id': id,
    };

    await dio.post('poll-vote', data: data);
  }

  Future<List<PostModel>> getSavedPosts() async {
    try {
      final response = (await dio.get('saved')).data;
      return List.of(Map.of(response).get('posts'))
          .map((e) => PostModel.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  toggleSavePost(int id) async {
    await dio.post('save-post/$id');
  }

  Future<PostModel> sharePost(CreatePostModel post) async {
    final response = (await dio.post('share-post/${post.originalPost!.id}',
            data: await post.toRequest()))
        .data;

    return PostModel.fromJson(response['post']);
  }

  Future<CreatePostModel> getUpdatePost(int? id) async {
    final response = (await dio.get('/posts/$id/edit')).data;
    return CreatePostModel.fromJson(response['post']);
  }

  Future<void> removeMedia(int postId, List<FileModel> ids) async {
    for (FileModel id in ids) {
        await dio.post('delete-post-images/$postId/${id.id}');
    }
  }

  Future<PostModel> updatePost(CreatePostModel post) async {
    final response = (await dio.post('posts/${post.id}',
            data: await post.toRequest(update: true))).data;
    return PostModel.fromJson(response['post']);
  }

  Future<String> movePost(PostModel post, GroupModel group) async {
    final postId = post.id;
    final groupId = group.id;
    final response = Map<String, dynamic>.of(
        (await dio.post('move-post/$postId/$groupId')).data);
    return response.containsKey('message')
        ? response['message']
        : 'Post was moved.';
  }

  Future<void> deletePost(int id) async {
      await dio.post('posts/$id', data: {'_method': 'DELETE'});
  }
}
