// ignore_for_file: empty_catches

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/create_post.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/notification.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/services/auth.dart';
import 'package:qatar_speed/tools/services/chat.dart';
import 'package:qatar_speed/tools/services/misc.dart';
import 'package:qatar_speed/tools/services/posts.dart';
import 'package:qatar_speed/ui/home/story_view/widgets/story_view.dart';
import 'package:video_player/video_player.dart';

class HomeController extends GetxController {
  final groups = <GroupModel>[].obs;
  final stories = <UserModel>[].obs;
  final posts = <PostModel>[];
  final playerControllers = <VideoPlayerController>[];
  int page = 0;
  bool _isLoadingMore = false;
  bool canLoadMore = true;
  final _unreadConversations = 0.obs;
  bool errorLoading = false;
  bool isLoadingNotifications = true;
  RxMap<String, List<NotificationModel>> notifications =
      <String, List<NotificationModel>>{}.obs;

  bool _initialized = false;

  RxInt get unreadConversations => _unreadConversations;

  Future<void> getPosts() async {
    if (!_isLoadingMore && canLoadMore) {
      _isLoadingMore = true;
      final posts = await PostsWebService().getPosts(page: page);
      page++;
      if (posts.length < 10) {
        canLoadMore = false;
      }
      this.posts.addAll(posts);
      _isLoadingMore = false;
      update(['home_posts']);
    }
  }

  Future<void> getNotifications() async {
    try {
      final data = await MiscWsebService().getNotifications();
      notifications.clear();
      notifications.addAll(data);
    } on DioError {}
    isLoadingNotifications = false;
    update(['notifications']);
  }

  void setPosts(List<PostModel> posts) {
    this.posts.clear();
    this.posts.addAll(posts);
    update(['home_posts']);
  }

  void likePost(PostModel post) {
    if (post.isLiked ?? false) {
      post.isLiked = false;
      post.likes = post.likes! - 1;
    } else {
      post.isLiked = true;
      post.likes = post.likes! + 1;
    }
    unawaited(PostsWebService().togglePostLike(post));
    update();
  }

  void addComment({required int postId}) {
    final p = posts.firstWhere((element) => element.id == postId);
    //p.commentsNumber = (p.commentsNumber ?? -1) + 1;
    p.comments;
    update(['home_posts']);
    update();
  }

  Future<void> _getHomeData() async {
    final response = await MiscWsebService().getHomeData();
    groups.addAll(List.of(response['groups'])
        .map((element) => GroupModel.fromJson(element))
        .toList());
    update(['home_groups']);
    stories.addAll(List.of(response['stories'])
        .map((element) => UserModel.fromJson(element))
        .toList());
    stories.insert(0, Get.find<UserController>().user);
    update(['home_stories']);
  }

  Future<void> refreshStories() async {
    final response = await MiscWsebService().getHomeData();
    stories.clear();
    stories.addAll(List.of(response['stories'])
        .map((element) => UserModel.fromJson(element))
        .toList());
    stories.insert(0, Get.find<UserController>().user);
    update(['home_stories']);
  }

  countMessages() async {
    _unreadConversations.value =
        (await ChatWebService().getConversations())['conversations']!
            .where((element) => element.unread > 0)
            .length;
  }

  Future<String> reportPost(PostModel post, String raison) async {
    return await PostsWebService().reportPost(post.id, raison);
  }

  Future<String> blockUser(UserModel user) async {
    return await AuthWebService().blockUser(user.id);
  }

  Future<void> votePoll(int id, PostModel post) async {
    post.votedPoll = id;
    update(['home_posts']);
    await PostsWebService().votePoll(id, post.id);
  }

  Future<void>? deleteStory(StoryItem story, int index) async {
    stories[index].stories?.removeWhere((element) => element.id == story.id);
    if (stories[index].stories?.isEmpty ?? false) {
      stories.removeAt(index);
    }
    update(['home_stories']);
    await MiscWsebService().deleteStory(story.id);
  }

  void stopAllPlayers() {
    playerControllers
        .where(
            (element) => element.value.isInitialized && element.value.isPlaying)
        .forEach((element) {
      element.pause();
    });
  }

  void insertPost(PostModel post) {
    int index = 0;
    if (posts.where((element) => element.id == post.id).isNotEmpty) {
      index =
          posts.indexOf(posts.firstWhere((element) => element.id == post.id));
      posts.removeAt(index);
    }
    posts.insert(index, post);
    update(['home_posts']);
  }

  Future<void> sharePost(CreatePostModel post) async {
    final shared = await PostsWebService().sharePost(post);
    shared.originalPost = post.originalPost;
    insertPost(shared);
  }

  Future<void> movePost(PostModel post, GroupModel group) async {
    final message = await PostsWebService().movePost(post, group);
    Get.snackbar('Move post', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(.7),
        colorText: Colors.white);
  }

  Future<void> deletePost(PostModel post) async {
    await PostsWebService().deletePost(post.id);
    posts.remove(post);
    update(['home_posts']);
    Get.snackbar('Delete', 'Post was deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(.7),
        colorText: Colors.white);
  }

  initialize() {
    if (!_initialized) {
      _initialized = true;
      getPosts().catchError((_) {
        if (!errorLoading) {
          errorLoading = true;
          update(['home_posts', 'home_groups', 'home_stories']);
        }
      });
      _getHomeData().catchError((_) {
        if (!errorLoading) {
          errorLoading = true;
          update(['home_posts', 'home_groups', 'home_stories']);
        }
      });
      isLoadingNotifications = true;
      update(['notifications']);
      getNotifications();
    }
  }

  void reload() {
    errorLoading = false;
    groups.clear();
    stories.clear();
    posts.clear();
    update(['home_posts', 'home_groups', 'home_stories']);
    initialize();
  }

  @override
  void onInit() {
    super.onInit();
    //initialize();
  }

  @override
  void onClose() {
    groups.clear();
    stories.clear();
    posts.clear();
    super.onClose();
  }

  void close() {
    groups.clear();
    stories.clear();
    posts.clear();
    page = 0;
    playerControllers.clear();
    _initialized = false;
    _isLoadingMore = false;
    canLoadMore = true;
    _unreadConversations.value = 0;
    errorLoading = false;
    isLoadingNotifications = true;
    notifications.clear();
  }

  void readNotification(NotificationModel notification) {
    /*notifications.forEach((key, value) {
      if (value.contains(notification)) {
        value.remove(notification);
      }
    });*/
    //notifications.removeWhere((key, value) => value.isEmpty);
    if (!notification.isRead) {
      MiscWsebService().readNotification(notification);
    }
    notification.isRead = true;
    notifications.refresh();
    update(['notifications']);
  }
}
