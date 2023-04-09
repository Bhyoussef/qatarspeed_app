import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime_type/mime_type.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/create_post.dart';
import 'package:qatar_speed/models/file.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/poll.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/services/posts.dart';
import 'package:video_player/video_player.dart';

enum PostType { poll, images, video }

class CreatePostController extends GetxController {
  final postController = TextEditingController();
  bool showErrorPolls = false;
  final List<String> privacyOptions = const [
    'Everyone',
    'Only Me',
    'People I Follow',
    'People Follow Me',
  ];

  bool get isPolls =>
      selectedType == PostType.poll || (post.polls?.isNotEmpty ?? false);

  CreatePostModel? _post;
  bool showPrivacy = false;
  PostType? selectedType;
  VideoPlayerController? _videoController;
  double videoAspectRatio = 16 / 9;
  List<PollModel> pollsToRemove = [];
  List<FileModel> filesToRemove = [];
  bool isLoading = false;

  VideoPlayerController get videoController => _videoController!;

  CreatePostModel get post => _post!;

  set post(CreatePostModel pst) {
    isLoading = true;
    update();
    PostsWebService().getUpdatePost(pst.id).then((value) {
      _post = value;
      postController.text = post.title ?? '';
      selectedType = (post.polls?.isNotEmpty ?? false)
          ? PostType.poll
          : ((post.media?.isNotEmpty ?? false) &&
                  (mime(post.media?.first.file)?.contains('video') ?? false))
              ? PostType.video
              : (post.media != null && (post.media?.length ?? 0) > 0)
                  ? PostType.images
                  : null;
      if (selectedType == PostType.video) {
        addMedia(post.media!.first);
      }
      isLoading = false;
      update();
    });
  }

  bool validate() {
    if ([PostType.video, PostType.images].contains(selectedType) &&
        (post.media?.isEmpty ?? false) &&
        postController.text.isEmpty) {
      _showDeletePostDialog();
      return false;
    }
    post.polls?.removeWhere((element) => element.text.isEmpty);

    if (isPolls && post.polls!.length < 2) {
      showErrorPolls = true;
      try {
        if (post.polls!.last.text.isNotEmpty) {
          post.polls!.add(PollModel());
        }
      } catch (e) {
        post.polls!.add(PollModel());
      }
      update();
      return false;
    }
    return true;
  }

  void selectPostType(PostType type) {
    if (type == selectedType) {
      selectedType = null;
    } else {
      selectedType = type;
    }
    if (selectedType != PostType.video) {
      _videoController?.dispose();
    }
    update();
  }

  void setPrivacy(String privacy) {
    post.privacy = privacy;
    update();
  }

  void changeComments(bool val) {
    post.commentStatus = val;
    update();
  }

  void setPoll(int index, String answer) {
    try {
      post.polls![index] = PollModel(text: answer);
    } on RangeError {
      if (post.polls![index - 1].text.isNotEmpty) {
        post.polls!.add(PollModel(text: answer));
      }
    }

    post.polls!.removeWhere((element) => element.text.isEmpty);
    try {
      if (post.polls!.last.text.isNotEmpty) {
        post.polls!.add(PollModel());
      }
    } catch (e) {
      post.polls!.add(PollModel());
    }
    if (answer.isEmpty) update();
  }

  void addMedia(FileModel file) {
    post.media!.add(file);
    if (selectedType == PostType.video) {
      if (file.file.startsWith('htttp')) {
        _videoController = VideoPlayerController.network(file.file,
            videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: false, mixWithOthers: false));
      } else {
        _videoController = VideoPlayerController.file(File(file.file),
            videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: false, mixWithOthers: false));
      }
      videoController.initialize().then((value) {
        videoAspectRatio = videoController.value.aspectRatio;
        update();
        videoController.addListener(() {
          update();
        });
      });
    }
    update();
  }

  void removeMedia(FileModel file) {
    if (file.file.startsWith('http')) {
      filesToRemove.add(file);
    }
    if (selectedType == PostType.video) {
      videoAspectRatio = 16 / 9;
      _videoController?.dispose().then((value) {
        update();
      });
    }
    post.media!.remove(file);
    update();
  }

  void togglePrivacy() {
    showPrivacy = !showPrivacy;
    update();
  }

  void addPost({GroupModel? group}) async {
    try {
      Get.back();
      post.title = postController.text;
      post.groupId = group?.id;
      final addedPost = await PostsWebService().createPost(post);
      Get.find<HomeController>().insertPost(addedPost);
    } on DioError catch (e) {
      debugPrint(e.toString());
    }
  }

  void sharePost(CreatePostModel post) {
    Get.back(result: post);
  }

  Future<PostModel> updatePost() async {
    post.title = postController.text;
    if (filesToRemove.isNotEmpty) {
      await PostsWebService().removeMedia(post.id, filesToRemove);
      filesToRemove.clear();
    }
    final updatedPost = await PostsWebService().updatePost(post);
    updatedPost.originalPost = post.originalPost;
    Get.find<HomeController>().insertPost(updatedPost);
    return updatedPost;
  }

  void setPost(PostModel? post) {
    if (post == null) {
      return;
    }
    _post = post.toUpdate();
    postController.text = post.text ?? '';
    if (post.polls.isNotEmpty) {
      selectedType = PostType.poll;
    } else if (post.media.length > 1) {
      selectedType = PostType.images;
    } else if (post.media.isNotEmpty) {
      if (mime(post.media.first.file)?.contains('video') ?? false) {
        _videoController = VideoPlayerController.network(post.media.first.file,
            videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: false, mixWithOthers: false));
        videoController.initialize().then((value) {
          videoAspectRatio = videoController.value.aspectRatio;
          update();
          videoController.addListener(() {
            update();
          });
        });
        selectedType = PostType.video;
      } else {
        selectedType = PostType.images;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _post = CreatePostModel();
  }

  @override
  void onClose() {
    post.media?.addAll(filesToRemove);
    Get.find<HomeController>().update(['home_posts']);
    _post = null;
    selectedType = null;
    _videoController?.removeListener(() {});
    _videoController?.dispose();
    super.onClose();
  }

  void _showDeletePostDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => WillPopScope(
        onWillPop: () async => !isLoading,
        child: AlertDialog(
          title: const Text('Delete'),
          content: const Text('Will this post will be deleted'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep update')),
            TextButton(
                onPressed: () {
                  isLoading = true;
                  update();
                  Get.find<HomeController>()
                      .deletePost(PostModel(id: post.id))
                      .then((_) {
                    isLoading = false;
                    update();
                    Navigator.of(context).pop();
                    Get.back(closeOverlays: true);
                  });
                },
                child: const Text('Ok'))
          ],
        ),
      ),
      barrierDismissible: !isLoading,
    );
  }
}
