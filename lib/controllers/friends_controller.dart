import 'dart:async';

import 'package:get/get.dart';
import 'package:qatar_speed/models/friends.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/services/friends.dart';

class FriendsController extends GetxController {
    FriendsModel friends = FriendsModel();
    bool isLoading = true;
    bool isLoadingMore = false;
    bool canLoadMoreFollowers = true;
    bool canLoadMoreFollowing = true;
    String? keyword;
    int page = 0;
    Timer? _debounce;

    Future<void> getFriends() async {
      if (!isLoadingMore) {
        isLoadingMore = true;
        update();
        final list = await FriendsWebService().getFriends(page: page);
        friends.following.addAll(list.following);
        friends.followers.addAll(list.followers);
        canLoadMoreFollowers = list.followers.length == 10;
        canLoadMoreFollowing = list.following.length == 10;
        isLoading = false;
        isLoadingMore = false;
        update();
      }
    }

    Future<bool> toggleFollowing(UserModel user) async {
      final result = await FriendsWebService().toggleFollow(user.id);
      user.following = result;
      if (result) {
        friends.following.add(user);
      } else {
        friends.following.remove(user);
      }
      update();
      return result;
    }

    void searchUser(String? keyword) {
      friends.following.clear();
      friends.followers.clear();
      page = 0;
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }
      if (keyword?.isEmpty ?? true) {
        _searchFriends(keyword);
        return;
      }

      _debounce =  Timer(const Duration(milliseconds: 600), () {
        _searchFriends(keyword);
      });
    }

    Future<void> _searchFriends(String? keyword) async {
      if (!isLoadingMore) {
        isLoadingMore = true;
        final list = await FriendsWebService().getFriends(keyword: keyword);
        friends.following.addAll(list.following);
        friends.followers.addAll(list.followers);
        canLoadMoreFollowers = list.followers.length == 10;
        canLoadMoreFollowing = list.following.length == 10;
        update();
        isLoadingMore = false;
      }
    }

    void loadMore() {
      page++;
      if (keyword != null) {
        _searchFriends(keyword);
      } else {
        getFriends();
      }
    }

    @override
  void onInit() {
    super.onInit();
    isLoading = true;
    getFriends();
  }
}