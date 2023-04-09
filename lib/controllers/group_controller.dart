import 'package:get/get.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/services/misc.dart';
import 'package:qatar_speed/tools/services/posts.dart';

class GroupController extends GetxController {
  late GroupModel group;
  bool isLoading = true;
  bool canLoadMore = true;
  bool isLoadingMore = false;
  int page = -1;


  void setGroup(GroupModel group) {
    this.group = group;
    update();
    getGroupPosts();
  }

  Future<void> getGroupPosts() async {
    if (!isLoadingMore && canLoadMore) {
      page++;
      isLoadingMore = true;
      final posts = await PostsWebService().getGroupPosts(
          groupId: group.id!, page: page);
      if (page == 0) {
        group.posts = [];
      }
      group.posts.addAll(posts);
      canLoadMore = posts.length == 10;
      isLoading = false;
      isLoadingMore = false;
      update();
    }
  }

  Future<void> toggleJoin() async {
    final result = await MiscWsebService().toggleGroupJoin(group.id!);
    group.joined = result;
    update();
  }

  void updatePost(PostModel post) {
    Get.find<HomeController>().insertPost(post);
    final index = group.posts.indexWhere((element) => element.id == post.id);
    group.posts..removeAt(index)..insert(index, post);
    update();
  }

  void removePost(PostModel post) {
    group.posts.remove(post);
    update();
  }

  @override
  void onClose() {
    super.onClose();
    group.posts = [];
  }

  void insertPost(PostModel post) {
    int index = 0;
    if (group.posts.where((element) => element.id == post.id).isNotEmpty) {
      final index =
      group.posts.indexOf(group.posts.firstWhere((element) => element.id == post.id));
      group.posts.removeAt(index);
    }
    group.posts.insert(index, post);
    update();
  }
}