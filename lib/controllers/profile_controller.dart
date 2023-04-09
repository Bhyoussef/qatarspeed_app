import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/auth.dart';
import 'package:qatar_speed/tools/services/posts.dart';

class ProfileController extends GetxController {
  UserModel? profile;
  bool isMyProfile = false;
  bool isFetchingPosts = true;
  List<PostModel> posts = [];
  bool isLoadingMore = false;
  bool canLoadMore = true;
  bool isLoadingBlockedUsers = false;
  int page = 0;
  List<UserModel> blockedUsers = [];

  void setProfile(UserModel profile) {
    this.profile = profile;
    isMyProfile = profile.id == Get.find<UserController>().user.id;
    getPosts();
    update();
  }

  getPosts() async {
    if (!isLoadingMore && canLoadMore) {
      isLoadingMore = true;
      final posts =
          await PostsWebService().getPosts(userId: profile!.id, page: page);
      this.posts.addAll(posts);
      canLoadMore = posts.length == 10;
      page++;
      isFetchingPosts = false;
      isLoadingMore = false;
      update();
    }
  }

  void removeProfile() {
    profile = null;
  }

  @override
  void onClose() {
    super.onClose();
    profile = null;
    isFetchingPosts = true;
    posts.clear();
    isLoadingMore = false;
    canLoadMore = true;
    page = 0;
  }

  Future<UserModel> updatePhoto(String path, bool isProfilePicture) async {
    final response = await AuthWebService().updatePhoto(path, isProfilePicture);
    final userController = Get.find<UserController>();
    if (isProfilePicture) {
      userController.user.photo = Res.baseUrl + response['image'];
    } else {
      userController.user.cover = Res.baseUrl + response['cover'];
    }

    userController.setUser(userController.user);
    return userController.user;
  }

  Future<List<PostModel>> getSavedPosts() async {
    List<PostModel> posts = [];
    isFetchingPosts = true;
    update(['saved_posts']);
    posts.addAll(await PostsWebService().getSavedPosts());
    isFetchingPosts = false;
    update(['saved_posts']);
    return posts;
  }

  Future<void> getBlockedUsers() async {
    blockedUsers.clear();
    isLoadingBlockedUsers = true;
    update(['blocked_users']);
    blockedUsers.addAll(await AuthWebService().getBlockedUsers());
    isLoadingBlockedUsers = false;
    update(['blocked_users']);
  }

  togglePostSave(PostModel post) async {
    await PostsWebService().toggleSavePost(post.id);
  }

  void deletePost(PostModel post) {
    posts.remove(post);
    Get.find<HomeController>().deletePost(post);
    update();
  }

  void insertPost(PostModel post) {
    final index = posts.indexWhere((element) => element.id == post.id);
    posts.removeAt(index);
    posts.insert(index, post);
    update();
  }

  toggleFollow() async {
    final response = await AuthWebService().toggleFollow(profile!.id);
    profile!.following = response;
    update();
  }

  Future<void> unblockUser(UserModel user) async {
    bool dismissible = true;
    await showDialog(
        context: Get.context!,
        barrierDismissible: dismissible,
        builder: (context) => WillPopScope(
              onWillPop: () async => dismissible,
              child: AlertDialog(
                title: const Text('Unblock'),
                content: Text('Do you want to unblock ${user.name}?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No')),
                  TextButton(
                      onPressed: () {
                        dismissible = false;
                        toggleBlockUser(user).then((_) {
                          dismissible = true;
                          Navigator.pop(context);
                        });
                      },
                      child: const Text('Yes')),
                ],
              ),
            ));
  }

  Future<void> toggleBlockUser(UserModel user) async {
    final result = await AuthWebService().toggleBlock(user);
    if (!result) {
      blockedUsers.remove(user);
    } else {
      blockedUsers.add(user);
    }
    update(['blocked_users']);
  }
}
