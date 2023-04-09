import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/profile_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/auth.dart';
import 'package:qatar_speed/ui/chat/chat_list_screen.dart';
import 'package:qatar_speed/ui/common/post_bottom_sheet.dart';
import 'package:qatar_speed/ui/common/post_widget.dart';
import 'package:qatar_speed/ui/common/refresh_loadmore.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/profile/settings/settings_screen.dart';
import 'package:qatar_speed/ui/profile/social_button.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, this.user}) : super(key: key);

  final UserModel? user;

  @override
  createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollController = ScrollController();

  bool _isMyProfile = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final controller = Get.find<ProfileController>();
      controller.setProfile(widget.user ?? Get.find<UserController>().user);
      _isMyProfile = controller.isMyProfile;
      _initForeignUser();
    });

    _initAppbar();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  @override
  void didPush() {
    super.didPush();
    _initAppbar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ProfileController>(builder: (controller) {
        return _ProfileContent(
          context: context,
          scrollController: _scrollController,
          controller: controller,
        );
      }),
    );
  }

  void _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.scrollController.value = _scrollController;
      Res.showAppBar.value = true;
      Res.titleWidget.value = null;
      if (_isMyProfile) {
        Res.appBarActions.value = [
          InkWell(
            onTap: () {
              Get.to(() => const SettingsScreen());
            },
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(
                CupertinoIcons.gear_alt,
                color: Colors.black,
              ),
            ),
          )
        ];
      }
    });
  }

  Future<void> _initForeignUser() async {
    final profileController = Get.find<ProfileController>();
    final profile =
        await AuthWebService().getUser(profileController.profile!.id);
    profileController.setProfile(profile);
    if (profileController.isMyProfile) {
      Get.find<UserController>().setUser(profile);
    }
  }
}

class _ProfileContent extends StatelessWidget {
  final ScrollController scrollController;
  final ProfileController controller;
  final BuildContext context;

  const _ProfileContent(
      {required this.scrollController,
      required this.controller,
      required this.context});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          _profileHeader(),
          const SizedBox(height: 10.0),
          _userInfo(),
          const SizedBox(
            height: 10.0,
          ),
          _counters(),
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Res.isPhone ? 25.0 : 55.0),
            child: const Divider(
              color: Colors.grey,
            ),
          ),
          if (controller.isFetchingPosts)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            )
          else if (controller.posts.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
              child: Text(
                'No posts for ${controller.isMyProfile ? 'you' : 'controller.profile?.name!'} yet',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontFamily: 'arial', fontSize: 18.0),
              ),
            )
          else
            _posts(),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    final photoSize = Res.isPhone ? 90.0 : 120.0;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: photoSize / 2),
          child: AspectRatio(
            aspectRatio: 1 / .40,
            child: GestureDetector(
              onTap: () => controller.isMyProfile
                  ? _onImageTap(isProfilePicture: false)
                  : _showImage(controller.profile!.cover!),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: controller.profile?.cover ?? '',
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
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (controller.isMyProfile)
                    Positioned(
                      bottom: 3.0,
                      right: 20.0,
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.white60,
                        size: Res.isPhone ? 35.0 : 40.0,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: .0,
          left: Res.isPhone ? 10.0 : 20.0,
          child: GestureDetector(
            onTap: () => controller.isMyProfile
                ? _onImageTap()
                : _showImage(controller.profile!.photo!),
            child: Stack(
              children: [
                Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1.0),
                    ),
                    margin: const EdgeInsets.only(right: 10.0),
                    child: ClipOval(
                        child: CachedNetworkImage(
                      imageUrl: controller.profile?.photo ?? '',
                      placeholder: (context, _) => ShimmerBox(
                        height: photoSize,
                        width: photoSize,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: photoSize,
                        height: photoSize,
                        color: Colors.black,
                      ),
                      width: photoSize,
                      height: photoSize,
                      fit: BoxFit.cover,
                    ))),
                if (controller.isMyProfile)
                  Positioned(
                    bottom: 6.0,
                    right: .0,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff0066FF),
                            ),
                            padding: EdgeInsets.all(Res.isPhone ? 1.0 : 2.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: Res.isPhone ? null : 30.0,
                            )),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
        Positioned(
            bottom: Res.isPhone ? -0.0 : 20.0,
            left: Res.isPhone ? 240.0 : 20.0,
            child: Container(
                width: 140,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo2.png',
                        height: 32,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        controller.profile?.id.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff343434)),
                      ),
                    ],
                  ),
                )))
      ],
    );
  }

  Widget _userInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Res.isPhone ? 25.0 : 55.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.profile?.type != null)
                      Text(
                        controller.profile!.type!.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Res.isPhone ? null : 18.0,
                          color: controller.profile?.color ?? Colors.black,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.profile?.username ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: Res.isPhone ? 18.0 : 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Material(
                      textStyle: TextStyle(
                          color: const Color(0xff19295C),
                          fontFamily: 'arial',
                          fontSize: Res.isPhone ? 12.0 : 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.profile?.name ?? '',
                          ),
                          Text(
                              'Joined ${formatDate(controller.profile?.updatedAt ?? DateTime.now(), [
                                dd,
                                '/',
                                mm,
                                '/',
                                yyyy
                              ])}'),
                          Text(controller.profile?.city ?? ''),
                          Text(controller.profile?.about ?? ""),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!controller.isMyProfile) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MaterialButton(
                                  height: 40,
                                  minWidth: 100,
                                  color: Colors.grey.shade200,
                                  onPressed: () => Get.to(() => ChatListScreen(
                                        user: controller.profile,
                                      )),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(Icons.message_outlined),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Message'),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MaterialButton(
                                  height: 40,
                                  minWidth: 100,
                                  color: Colors.grey.shade200,
                                  onPressed: () => controller.toggleFollow(),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.person),
                                      Text((controller.profile?.following ??
                                              false)
                                          ? 'Unfollow'
                                          : 'Follow'),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          //Text(controller.profile?.about ?? ""),
        ],
      ),
    );
  }

  Widget _counters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Res.isPhone ? 20.0 : 150.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _counterText(
                  key: 'Posts',
                  value: controller.profile?.postsCount?.toString() ?? '0'),
              _counterText(
                  key: 'Following',
                  value: controller.profile?.followingCount?.toString() ?? '0'),
              _counterText(
                  key: 'Followers',
                  value: controller.profile?.followersCount?.toString() ?? "0"),
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          MasonryGridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10.0,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            children: [
              if (controller.profile?.snapchat != null)
                SocialButton(
                  type: SocialType.Snapchat,
                  onTap: () =>
                      launchUrl(Uri.parse(controller.profile!.snapchat ?? '')),
                ),
              if (controller.profile?.instagram != null)
                SocialButton(
                    type: SocialType.Instagram,
                    onTap: () => launchUrl(
                          Uri.parse(controller.profile!.instagram ?? ''),
                        )),
              if (controller.profile?.tiktok != null)
                SocialButton(
                  type: SocialType.Tiktok,
                  onTap: () =>
                      launchUrl(Uri.parse(controller.profile!.tiktok ?? '')),
                ),
              if (controller.profile?.phone != null)
                SocialButton(
                  type: SocialType.Whatsapp,
                  onTap: () => launchUrl(
                      Uri.parse('https://wa.me/${controller.profile!.phone!}')),
                ),
              if (controller.profile?.twitter != null)
                SocialButton(
                    type: SocialType.Twitter,
                    onTap: () => launchUrl(
                          Uri.parse(controller.profile!.twitter ?? ''),
                        )),
              if (controller.profile?.facebook != null)
                SocialButton(
                  type: SocialType.Facebook,
                  onTap: () =>
                      launchUrl(Uri.parse(controller.profile!.facebook ?? '')),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _counterText({required String key, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w600,
              color: Color(0xff343434)),
        ),
        Text(
          key,
          style: const TextStyle(color: Color(0xff343434)),
        )
      ],
    );
  }

  Widget _posts() {
    if (controller.isFetchingPosts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        )),
      );
    }
    return RefreshLoadmore(
      isLastPage: !controller.canLoadMore,
      noMoreWidget: Container(),
      onLoadmore: () => controller.getPosts(),
      scrollController: scrollController,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.posts.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        itemBuilder: (context, index) {
          final post = controller.posts[index];
          return PostWidget(
            post: post,
            canTapUser: false,
            onPostSelected: (post) => showPostBottomSheet(post,
                onDeletePost: () {
                  controller.deletePost(post);
                },
                onPostEdited: (post) {
                  controller.insertPost(post);
                },
                onBlockUser: () {},
                onMovePost: (group) {
                  Get.find<HomeController>().movePost(post, group);
                }),
          );
        },
      ),
    );
  }

  _onImageTap({bool isProfilePicture = true}) {
    showModalBottomSheet(
        isScrollControlled: false,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.fullscreen),
                  enabled: (isProfilePicture &&
                          controller.profile?.photo != null) ||
                      (!isProfilePicture && controller.profile?.cover != null),
                  onTap: () {
                    Get.back();
                    _showImage(isProfilePicture
                        ? controller.profile!.photo!
                        : controller.profile!.cover!);
                  },
                  title: Text(
                      'See ${isProfilePicture ? 'profile picture' : 'cover photo'}'),
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  onTap: () => _changePicture(isProfilePicture),
                  title: Text(
                      'Change ${isProfilePicture ? 'profile picture' : 'cover photo'}'),
                ),
              ],
            ),
          );
        });
  }

  void _showImage(String path) {
    showImageViewer(context, CachedNetworkImageProvider(path));
  }

  _changePicture(bool isProfilePicture) async {
    final paths = await ImagePickers.pickerPaths(
      galleryMode: GalleryMode.image,
      showCamera: true,
      selectCount: 1,
    );

    Get.back();

    if (paths.isNotEmpty) {
      controller.setProfile(
          await controller.updatePhoto(paths.first.path!, isProfilePicture));
    }
  }
}
