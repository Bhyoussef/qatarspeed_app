import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/profile_controller.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/posts/post_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class SavedPostsSettingsScreen extends StatefulWidget {
  const SavedPostsSettingsScreen({Key? key}) : super(key: key);

  @override
  createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsSettingsScreen>
    with RouteAware, RouteObserverMixin {
  List<PostModel> _posts = [];

  @override
  void initState() {
    super.initState();

    Get.find<ProfileController>().getSavedPosts().then((value) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _posts = value;
        });
      });
    });
  }

  @override
  void didPopNext() {
    super.didPopNext();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  void didPush() {
    super.didPush();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: GetBuilder<ProfileController>(
          id: 'saved_posts',
            builder: (controller) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark,
                    size: Res.isPhone ? 50.0 : 60.0,
                  ),
                  Text(
                    'Manage saved posts',
                    style: TextStyle(
                        fontFamily: 'arial',
                        fontSize: Res.isPhone ? 16.0 : 19.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              if (controller.isFetchingPosts)
                Padding(
                  padding: EdgeInsets.only(top: Get.height * .25),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                )
              else
                ..._posts.map((e) => _postItem(e, controller)).toList(),
            ],
          );
        }),
      ),
    );
  }

  Widget _doneBtn() {
    return TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Done'));
  }

  Widget _postItem(PostModel post, ProfileController controller) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
          color: Colors.red,
          padding:
          const EdgeInsets.symmetric(horizontal: 10.0),
          child: const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          )),
      onDismissed: (_) => controller.togglePostSave(post),
      child: InkWell(
        onTap: () => Get.to(() => PostScreen(post: post)),
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (post.media.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: post.media[0].file,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => ShimmerBox(
                        width: Res.isPhone ? 80.0 : 60.0,
                        height: Res.isPhone ? 80.0 : 60.0,
                      ),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                      width: Res.isPhone ? 80.0 : 60.0,
                      height: Res.isPhone ? 80.0 : 60.0,
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(child: Text(post.text ?? '')),
                    const SizedBox(
                      width: 20.0,
                    )
                  ],
                ),
                const Positioned(top: .0, right: .0, child: Icon(Icons.bookmark))
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
