import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/services/misc.dart';
import 'package:qatar_speed/ui/common/post_bottom_sheet.dart';
import 'package:qatar_speed/ui/common/post_widget.dart';
import 'package:qatar_speed/ui/common/refresh_loadmore.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/common/story_screen.dart';
import 'package:qatar_speed/ui/groups/groups_screen.dart';
import 'package:qatar_speed/ui/home/story_list_item.dart';
import 'package:qatar_speed/ui/home/story_view/create_video_story.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:story_creator/story_creator.dart';

import '../../controllers/user_controller.dart';
import '../../tools/res.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollViewController = ScrollController();
  final user = Get
      .find<UserController>()
      .user;
  final _visibleFab = true.obs;

  Widget _titleWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent, width: 1.5),
                color: Colors.transparent),
            padding: const EdgeInsets.all(1.0),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.photo ?? '',
                placeholder: (context, _) =>
                    ShimmerBox(
                      width: Res.isPhone ? 38.0 : 40.0,
                      height: Res.isPhone ? 38.0 : 40.0,
                    ),
                errorWidget: (_, __, ___) =>
                    Container(
                      width: Res.isPhone ? 38.0 : 40.0,
                      height: Res.isPhone ? 38.0 : 40.0,
                      color: Colors.black,
                    ),
                width: Res.isPhone ? 38.0 : 40.0,
                height: Res.isPhone ? 38.0 : 40.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall,
              ),
              Text(
                user.name ?? '',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didPush() {
    super.didPush();
    _initAppbar();
  }

  @override
  void didPop() {
    Res.isHome.value = false;
    super.didPop();
  }

  @override
  void didPushNext() {
    Res.isHome.value = false;
    Res.titleWidget.value = null;
    super.didPushNext();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.scrollController.value = _scrollViewController;
      Res.titleWidget.value = _titleWidget();
      Res.isHome.value = true;
      Res.showAppBar.value = true;
      Res.appBarActions.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    Get.find<HomeController>().initialize();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(() {
        return AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _visibleFab.value ? 1.0 : .0,
          // child: FloatingActionButton(
          //   heroTag: 'edit_post',
          //   shape: const CircleBorder(),
          //   onPressed: () => Get.to(() => const EditPostScreen()),
          //   tooltip: 'Add post',
          //   backgroundColor: Colors.black,
          //   child: const Icon(
          //     Icons.add,
          //     color: Colors.white,
          //   ),
          // ),
        );
      }),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notif) {
          if (notif.direction == ScrollDirection.forward) {
            _visibleFab.value = true;
          } else if (notif.direction == ScrollDirection.reverse) {
            _visibleFab.value = false;
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollViewController,
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              _storiesList(),
              _groupsList(),
              _posts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storiesList() {
    return SizedBox(
      height: Res.isPhone ? 70.0 : 84.0,
      child: GetBuilder<HomeController>(
          id: 'home_stories',
          builder: (controller) {
            return ListView.builder(
              itemCount: controller.stories.length == 1
                  ? 4
                  : controller.stories.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                UserModel? story = controller.stories.length == 1
                    ? null
                    : controller.stories[index];
                return StoryListItem(
                  story: story,
                  isMine: index == 0,
                  onTap: (story) {
                    if (index == 0) {
                      _createStory();
                    } else {
                      Navigator.of(Res.baseContext).push(MaterialPageRoute(
                        builder: (context) =>
                            StoryScreen(
                              index: controller.stories.indexOf(story),
                              stories: controller.stories,
                            )));
                    }
                  },
                );
              },
            );
          }),
    );
  }

  Widget _groupsList() {
    final size = Res.isPhone ? 120.0 : 145.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Divider(
            color: Colors.blueGrey,
            thickness: .5,
            height: 1.0,
          ),
        ),
        const SizedBox(
          height: 6.0,
        ),
        SizedBox(
          height: 150,
          child: GetBuilder<HomeController>(
            id: 'home_groups',
            builder: (controller) =>
                ListView.builder(
                  itemCount:
                  controller.groups.isEmpty ? 18 : controller.groups.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    GroupModel? group;
                    if (controller.groups.isNotEmpty) {
                      group = controller.groups[index];
                    }
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: InkWell(
                            onTap: () {
                              Get.to(() =>
                                  GroupsScreen(
                                    group: group,
                                  ));
                            },
                            child: group == null
                                ? ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: ShimmerBox(
                                  height: size,
                                  width: size,
                                ))
                                : Stack(
                              children: [
                                Container(
                                  foregroundDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(
                                          color: Colors.black, width: 1.0),
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(.7),
                                            Colors.transparent
                                          ],
                                          stops: const [
                                            0,
                                            .8,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter)),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: CachedNetworkImage(
                                        imageUrl: group.image ?? '',
                                        placeholder: (context, _) =>
                                            ShimmerBox(
                                              width: double.infinity,
                                              height: size,
                                            ),
                                        errorWidget: (_, __, ___) =>
                                            Container(
                                              width: double.infinity,
                                              height: size,
                                              color: Colors.black,
                                            ),
                                        width: size,
                                        height: size,
                                        fit: BoxFit.cover,
                                      )),

                                ),

                                // Positioned(
                                //   bottom: 6.0,
                                //   left: .0,
                                //   right: .0,
                                //   child: Center(
                                //     child: SizedBox(
                                //       width: size - 10.0,
                                //       child: Text(
                                //         group.name ?? '',
                                //         maxLines: 2,
                                //         style: TextStyle(
                                //             color: Colors.white,
                                //             fontFamily: 'fg',
                                //             fontSize: Res.isPhone ? 10.0 : 15.0,
                                //             fontWeight: FontWeight.w100),
                                //         textAlign: TextAlign.center,
                                //       ),
                                //     ),
                                //   ),
                                // ),

                              ],
                            ),


                          ),

                        ),
                        Row(
                          children: [
                            Text(
                              group?.name ?? '',
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'fg',
                                  fontSize: Res.isPhone ? 14.0 : 14.0,
                                  fontWeight: FontWeight.w100),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Divider(
            color: Colors.blueGrey,
            thickness: .5,
          ),
        ),
      ],
    );
  }

  Widget _posts() {
    return GetBuilder<HomeController>(
        id: 'home_posts',
        builder: (controller) =>
        controller.errorLoading ?
        Padding(
          padding: EdgeInsets.only(top: Get.height * .2),
          child: Center(child:
          InkWell(
            onTap: () => controller.reload(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.refresh, color: Colors.grey,),
                SizedBox(height: 8,),
                Text('Refresh', style: TextStyle(color: Colors.grey),)
              ],
            ),
          ),),
        )
            :
        controller.posts.isEmpty
            ? const Padding(
          padding: EdgeInsets.only(top: 150.0),
          child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              )),
        )
            : _HomePosts(
          controller: controller,
          scrollController: _scrollViewController,
        ));
  }

  Future<void> _createStory() async {
    GalleryMode? gMode = await showModalBottomSheet<GalleryMode>(
        context: context,
        builder: (context) =>
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(1.0))),
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(GalleryMode.image),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            color: Colors.grey,
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        const Text(
                          'From Image',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(GalleryMode.video),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            color: Colors.grey,
                            child: const Icon(
                              Icons.video_camera_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        const Text(
                          'From Video',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
    if (gMode == null) {
      return;
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.showAppBar.value = false;
      Res.showBottomBar.value = false;
    });
    final file = await ImagePickers.pickerPaths(
        selectCount: 1, showCamera: true, showGif: true, galleryMode: gMode);
    if (file.isNotEmpty) {
      Res.keyboardEventSubscription.pause();
      if (gMode == GalleryMode.video) {
        await Get.to(() =>
            CreateVideoStory(
              file: File(file.first.path!),
            ))?.then((file) {
          if (file != null) {
            MiscWsebService().createStory(file).then((value) {
              if (mounted) {
                Get.find<HomeController>().refreshStories();
              }
            });
          }
        });
      } else {
        await Get.to(() =>
            StoryCreator(
              filePath: file.first.path!,
            ))?.then((file) {
          if (file != null) {
            MiscWsebService().createStory(file).then((value) {
              if (mounted) {
                Get.find<HomeController>().refreshStories();
              }
            });
          }
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values)
            .then((value) => Res.initSystemOverlays());
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        Res.showAppBar.value = true;
        Res.showBottomBar.value = true;
      });
      Res.keyboardEventSubscription.resume();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values)
            .then((value) => Res.initSystemOverlays());
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        Res.showAppBar.value = true;
        Res.showBottomBar.value = true;
      });
    }
  }
}

class _HomePosts extends StatelessWidget {
  final HomeController controller;
  final ScrollController scrollController;

  const _HomePosts(
      {required this.controller, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return RefreshLoadmore(
      isLastPage: !controller.canLoadMore,
      scrollController: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      noMoreWidget: Container(),
      onLoadmore: () => controller.getPosts(),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.posts.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        itemBuilder: (context, index) {
          final post = controller.posts[index];
          return PostWidget(
            post: post,
            onPostSelected: (post) =>
                showPostBottomSheet(post,
                  onDeletePost: () =>
                      Get.find<HomeController>().deletePost(post),
                  onBlockUser: () {
                    controller
                        .blockUser(post.user!)
                        .then((response) =>
                        Get.dialog(AlertDialog(
                          content: Text(response),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(Res.baseContext),
                                child: const Text('Ok')),
                          ],
                        )));

                    controller.setPosts(controller.posts
                        .where((element) => element.user?.id != post.user?.id)
                        .toList());
                  },
                  onMovePost: (group) {
                    Get.find<HomeController>().movePost(post, group);
                  },),
          );
        },
      ),
    );
  }
}
