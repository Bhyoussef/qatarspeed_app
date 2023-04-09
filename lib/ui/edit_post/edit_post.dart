import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:qatar_speed/controllers/create_post_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/create_post.dart';
import 'package:qatar_speed/models/file.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/poll.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/post_widget.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:video_player/video_player.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen(
      {Key? key, this.group, this.post, this.sharingPost, this.onPost})
      : super(key: key);
  final GroupModel? group;
  final PostModel? post;
  final PostModel? sharingPost;
  final Function(PostModel)? onPost;

  @override
  createState() => _EditPostState();
}

class _EditPostState extends State<EditPostScreen>
    with RouteAware, RouteObserverMixin {
  @override
  void initState() {
    super.initState();
    Get.find<CreatePostController>().setPost(widget.post);
  }

  @override
  void didPush() {
    super.didPush();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.titleWidget.value = const Padding(
          padding: EdgeInsets.only(left: 15.0),
          );
      Res.isHome.value = true;
      Res.showAppBar.value = true;
      Res.appBarActions.clear();
    });
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

  Widget _titleWidget() {
    final user = Get.find<UserController>().user;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
              color: Colors.yellow),
          padding: const EdgeInsets.all(1.0),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.photo ?? '',
              placeholder: (context, _) => ShimmerBox(
                width: Res.isPhone ? 35.0 : 40.0,
                height: Res.isPhone ? 35.0 : 40.0,
              ),
              errorWidget: (_, __, ___) => Container(
                width: Res.isPhone ? 35.0 : 40.0,
                height: Res.isPhone ? 35.0 : 40.0,
                color: Colors.black,
              ),
              width: Res.isPhone ? 35.0 : 40.0,
              height: Res.isPhone ? 35.0 : 40.0,
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
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              user.name ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'edit_post',
        child: GetBuilder<CreatePostController>(builder: (controller) {
          return WillPopScope(
            onWillPop: () async => !controller.isLoading,
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        vertical: Get.mediaQuery.size.height * .05,
                        horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _postCard(controller),
                        const SizedBox(
                          height: 20.0,
                        ),
                        _privacyCard(controller),
                      ],
                    ),
                  ),
          );
        }),
      ),
    );
  }

  Widget _pill(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      required PostType type,
      required Color iconColor}) {
    final selectedType = Get.find<CreatePostController>().selectedType;
    final canTap = selectedType == null || selectedType == type;
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999.0),
      child: InkWell(
        onTap: () {
          onTap();
          FocusScope.of(context).unfocus();
        },
        borderRadius: BorderRadius.circular(9999.0),
        child: Container(
          width: Get.width * .30,
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          foregroundDecoration: BoxDecoration(
            color: canTap ? Colors.transparent : Colors.grey.withOpacity(.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(
                width: 5.0,
              ),
              Text(
                title,
                style: const TextStyle(fontFamily: 'arial'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _postCard(CreatePostController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
              MaterialButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        if (!controller.validate()) {
                          return;
                        }
                        if (widget.sharingPost != null) {
                          controller.sharePost(CreatePostModel(
                              title: controller.postController.text,
                              originalPost: widget.sharingPost));
                        } else if (widget.post != null) {
                          final post = await controller.updatePost();
                          if (widget.onPost != null) {
                            widget.onPost!(post);
                          }
                          Get.back();
                        } else {
                          controller.addPost(group: widget.group);
                        }
                      },
                textColor: Colors.white,
                minWidth: 80,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999)),
                child: Text(widget.sharingPost != null
                    ? 'Share'
                    : widget.post != null
                        ? 'Update'
                        : 'Post'),
              ),
            ],
          ),
        ),
        Card(
          color: const Color(0xffece9e9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //_titleWidget(),
                      TextField(
                        controller: controller.postController,
                        maxLines: 8,
                        minLines: 2,
                        decoration: const InputDecoration(
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            hintText: 'What\'s going on ?',
                            hintStyle: TextStyle(
                                fontFamily: 'arial', color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Column(
          children: [
            if (controller.selectedType == PostType.images)
              _selectedImages(controller)
            else if (controller.selectedType == PostType.video)
              _selectedVideo(controller)
            else if (controller.selectedType == PostType.poll)
              _polls(controller),
            if (widget.sharingPost == null && widget.post == null)
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  runSpacing: 15.0,
                  children: [
                    _pill(
                      title: 'Add Images',
                      icon: Icons.insert_photo_rounded,
                      onTap: () {
                        controller.post.media = [];
                        controller.post.polls = null;
                        controller.selectPostType(PostType.images);
                      },
                      iconColor: Colors.lightBlueAccent,
                      type: PostType.images,
                    ),
                    _pill(
                        title: 'Create Poll',
                        icon: Icons.poll,
                        onTap: () {
                          controller.post.media = null;
                          controller.post.polls = [PollModel()];
                          controller.selectPostType(PostType.poll);
                        },
                        iconColor: Colors.teal,
                        type: PostType.poll),
                    _pill(
                        title: 'Upload Video',
                        icon: Icons.videocam_rounded,
                        onTap: () {
                          controller.post.media = [];
                          controller.post.polls = null;
                          controller.selectPostType(PostType.video);
                        },
                        iconColor: Colors.lightGreen,
                        type: PostType.video),
                  ],
                ),
              )
            else if (widget.sharingPost != null ||
                widget.post?.originalPost != null)
              AbsorbPointer(
                  child: PostWidget(
                      post: widget.post?.originalPost ?? widget.sharingPost!)),
          ],
        ),
      ],
    );
  }

  Widget _privacyCard(CreatePostController controller) {
    return SizedBox(
      width: Get.width,
      child: Card(
        color: const Color(0xffece9e9),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text('Allow Comments'),
                  Switch(
                      value: controller.post.commentStatus,
                      activeColor: Colors.blue,
                      onChanged: (val) => controller.changeComments(val))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacyItem(
      String option, String value, Function(String?) onChanged) {
    return ListTile(
      title: Text(option),
      trailing: IgnorePointer(
        child: Radio<String>(
          groupValue: value,
          value: option,
          activeColor: Colors.black,
          onChanged: (txt) {
            onChanged(txt);
          },
        ),
      ),
      onTap: () => onChanged(option),
    );
  }

  Widget _selectedImages(CreatePostController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        height: 150.0,
        width: Get.width,
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          scrollDirection: Axis.horizontal,
          itemCount: controller.post.media!.length + 1,
          itemBuilder: (context, index) {
            final images = controller.post.media!;
            if (index > images.length - 1) {
              return _addImage((path) => controller.addMedia(path));
            } else {
              return _imageItem(
                  images[index], (file) => controller.removeMedia(file));
            }
          },
        ),
      ),
    );
  }

  Widget _addImage(Function(FileModel file) onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: DottedBorder(
        borderType: BorderType.RRect,
        color: Colors.black54,
        padding: EdgeInsets.zero,
        radius: const Radius.circular(5.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: () async {
            final path = await ImagePickers.pickerPaths(
                galleryMode: GalleryMode.image,
                showCamera: true,
                selectCount: 1,
                showGif: false);
            if (path.isNotEmpty) {
              onTap(FileModel(file: path.first.path!));
            }
          },
          child: SizedBox(
            width: 120.0,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: .3,
                  child: const Icon(
                    Icons.image,
                    color: Colors.black38,
                    size: 50.0,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Transform.rotate(
                  angle: .34,
                  child: const Text(
                    'Add image',
                    style:
                        TextStyle(fontFamily: 'arial', color: Colors.black54),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageItem(FileModel image, void Function(FileModel file) onTap) {
    final img = image.file;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: CachedNetworkImage(
                imageUrl: img,
                placeholder: (context, _) => const ShimmerBox(
                  width: 120.0,
                  height: 140,
                ),
                errorWidget: (_, __, ___) => Image.file(
                  File(img),
                  fit: BoxFit.cover,
                ),
                width: 120.0,
                height: 140.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: .0,
            top: .0,
            child: InkWell(
              onTap: () => onTap(image),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(5.0),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 13.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _selectedVideo(CreatePostController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: AspectRatio(
        aspectRatio: controller.videoAspectRatio,
        child: controller.post.media!.isEmpty
            ? DottedBorder(
                padding: EdgeInsets.zero,
                borderType: BorderType.RRect,
                radius: const Radius.circular(10.0),
                child: InkWell(
                  onTap: () async {
                    final media = await ImagePickers.pickerPaths(
                      galleryMode: GalleryMode.video,
                      showGif: false,
                      showCamera: true,
                      selectCount: 1,
                    );
                    if (media.isNotEmpty) {
                      controller.addMedia(FileModel(file: media.first.path!));
                    }
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: .3,
                          child: const Icon(
                            Icons.video_camera_back,
                            color: Colors.black38,
                            size: 50.0,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        const Text(
                          'Select video',
                          style: TextStyle(
                              fontFamily: 'arial', color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : _videoPlayer(controller),
      ),
    );
  }

  Widget _videoPlayer(CreatePostController controller) {
    VideoPlayerController? vController = controller.videoController;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: !controller.videoController.value.isInitialized
          ? Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : InkWell(
              onTap: () {
                if (vController.value.isPlaying) {
                  vController.pause();
                } else {
                  vController.play();
                }
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, right: 10.0, left: 10.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: VideoPlayer(
                            vController,
                          ),
                        ),
                        if (!vController.value.isPlaying)
                          const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 100.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: .0,
                    top: .0,
                    child: InkWell(
                      onTap: () =>
                          controller.removeMedia(controller.post.media!.first),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(5.0),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 13.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _polls(CreatePostController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.post.polls!.length,
              itemBuilder: (context, index) {
                final poll = controller.post.polls![index];
                final textController = TextEditingController();
                textController.text = poll.text;
                return TextField(
                  controller: textController,
                  onChanged: (txt) {
                    controller.setPoll(index, txt);
                  },
                  decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.grey),
                      hintText: 'Answer ${index + 1}',
                      suffixIcon: InkWell(
                        onTap: () {
                          if (poll is Map) {
                            controller.pollsToRemove.add(poll);
                          }
                          controller.setPoll(index, '');
                        },
                        child: const Icon(Icons.close),
                      )),
                );
              },
            ),
            if (controller.showErrorPolls)
              const Text(
                'Please insert at least 2 options',
                style: TextStyle(color: Colors.red, fontSize: 12.0),
              ),
            MaterialButton(
              onPressed: () =>
                  controller.setPoll(controller.post.polls!.length, ''),
              textColor: Colors.white,
              color: Colors.lightBlue,
              child: const Text('Add Answer'),
            )
          ],
        ),
      ),
    );
  }
}
