import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/group_controller.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/ui/common/post_bottom_sheet.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/edit_post/edit_post.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import '../../tools/res.dart';
import '../common/post_widget.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({
    Key? key,
    this.group,
  }) : super(key: key);
  final GroupModel? group;

  @override
  createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollViewController = ScrollController();
  final _vilibleFab = true.obs;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<GroupController>();
    controller.setGroup(widget.group!);
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.pixels > _scrollViewController.position.maxScrollExtent - 50) {
        controller.getGroupPosts();
      }
    });
  }

  @override
  void didPush() {
    super.didPush();
    _initAppbar();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.titleWidget.value = null;
      Res.appBarActions.clear();
      Res.scrollController.value = _scrollViewController;
    });
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupController>(builder: (controller) {
      return Scaffold(
        floatingActionButton: Obx(() {
          return AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: _vilibleFab.value ? 1.0 : .0,
            child: FloatingActionButton(
              heroTag: 'edit_post',
              shape: const CircleBorder(),
              onPressed: () => Get.to(() => EditPostScreen(
                    group: controller.group,
                onPost: (post) {
                      controller.group.posts.insert(0, post);
                      controller.update();
                },
                  )),
              tooltip: 'Add post',
              backgroundColor: Colors.black,
                child:  Image.asset('assets/tab.png')
            ),
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Column(
          children: [
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: (scroll) {
                  if (scroll.direction == ScrollDirection.forward) {
                    _vilibleFab.value = true;
                  } else if (scroll.direction == ScrollDirection.reverse) {
                    _vilibleFab.value = false;
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollViewController,
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _grpHeader(controller),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                        child: Divider(
                          color: Colors.blueGrey,
                          thickness: .5,
                        ),
                      ),
                      _posts(controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _posts(GroupController controller) {
    final posts = controller.group.posts;
    return controller.isLoading
        ? Center(
            child: Padding(
            padding: EdgeInsets.only(top: Get.height * .25),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ))
        : controller.group.posts.isEmpty
            ? Center(
                child: Padding(
                padding: EdgeInsets.only(top: Get.height * .2),
                child: const Text(
                  'No posts yet,\nbe the first interactor',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 20.0),
                ),
              ))
            : Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    itemBuilder: (context, index) {
                      return PostWidget(
                        post: posts[index],
                        onPostSelected: (post) => showPostBottomSheet(post,
                            onDeletePost: () {
                              Get.find<HomeController>().deletePost(post);
                              controller.group.posts.remove(post);
                              controller.update();
                            },
                            onPostEdited: (post) {
                                controller.updatePost(post);
                            },
                            onBlockUser: () {
                              Get.find<HomeController>().blockUser(post.user!)
                                  .then((response) => Get.dialog(AlertDialog(
                                content: Text(response),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(Res.baseContext),
                                      child: const Text('Ok')),
                                ],
                              )));
                            },
                            onMovePost: (group) {
                              if (controller.group != group) {
                                Get.find<HomeController>().movePost(post, group);
                                controller.group.posts.remove(post);
                                controller.update();
                              }
                            }),
                      );
                    },
                  ),
                if (controller.canLoadMore)
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(),
                  )
              ],
            );
  }

  _grpHeader(GroupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
            aspectRatio: 8 / (Res.isPhone ? 3.2 : 3.2),
            child: CachedNetworkImage(
              imageUrl: controller.group.cover ?? '',
              placeholder: (context, _) => const ShimmerBox(
                height: double.infinity,
                width: double.infinity,
              ),
              errorWidget: (_, __, ___) => Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
              width: double.infinity,
              fit: BoxFit.cover,
            )),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          controller.group.name ?? '',
                          style: TextStyle(
                              fontFamily: 'arial',
                              fontWeight: FontWeight.w900,
                              fontSize: Res.isPhone ? 14 : 17.0),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        InkWell(
                          onTap: controller.toggleJoin,
                          child: Text(
                            controller.group.joined ? 'Leave' : 'Join',
                            style: TextStyle(
                                fontFamily: 'arial',
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: Res.isPhone ? 14.0 : 17.0),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        controller.group.description ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: Res.isPhone ? 11 : 16.0,
                            fontFamily: 'arial'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
