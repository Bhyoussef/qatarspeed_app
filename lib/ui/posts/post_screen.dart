import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:qatar_speed/controllers/comments_controller.dart';
import 'package:qatar_speed/controllers/group_controller.dart';
import 'package:qatar_speed/controllers/home_controller.dart';

//import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:qatar_speed/models/comment.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/ui/common/comment_box.dart';
import 'package:qatar_speed/ui/common/comment_widget.dart';
import 'package:qatar_speed/ui/common/post_bottom_sheet.dart';
import 'package:qatar_speed/ui/common/post_widget.dart';
import 'package:qatar_speed/ui/common/tree_view/flexible_tree_view.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import '../../tools/res.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key, required this.post, this.toComment = false})
      : super(key: key);
  final PostModel post;
  final bool toComment;

  @override
  createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollController = ScrollController();

  @override
  void initState() {
    final controller = Get.find<CommentController>();
    controller.post = widget.post;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _getPost(controller);
      Get.find<CommentController>().initializeCommentsNodes(controller.post);
    });
    super.initState();
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
      Res.scrollController.value = _scrollController;
      Res.titleWidget.value = null;
      Res.appBarActions.clear();
      Res.showAppBar.value = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentController>(builder: (controller) {
      return Scaffold(
          bottomSheet: SolidBottomSheet(
            canUserSwipe: false,
            autoSwiped: true,
            draggableBody: false,
            toggleVisibilityOnTap: false,
            headerBar: AnimatedSize(
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 50),
              child: Container(
                color: Colors.black12,
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  children: [
                    if (controller.replyTo != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              'Reply to ${controller.replyTo?.user?.username}',
                              style: TextStyle(
                                  fontFamily: 'arial',
                                  fontWeight: FontWeight.w900,
                                  fontSize: Res.isPhone ? 10.0 : 15.0),
                            )),
                            InkWell(
                                onTap: () => controller.removeReply(),
                                child: Icon(
                                  Icons.close,
                                  size: Res.isPhone ? 15.0 : 25.0,
                                )),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: .15,
                      ),
                    ],
                    CommentBox(
                      onSend: (_) => _sendComment(controller),
                      onChanged: (txt) => controller.update(),
                      textController: controller.commentController,
                      focus: controller.focusNode,
                      autoFocus: widget.toComment,
                      hint: controller.replyTo == null
                          ? 'add comment'
                          : 'reply to ${controller.replyTo?.user?.username ?? 'comment'}',
                      suffixWidget: Icon(
                        controller.commentController.text
                                .replaceAll(' ', '')
                                .isNotEmpty
                            ? Icons.send
                            : Icons.camera_alt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Container(),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                PostWidget(
                  post: controller.post,
                  useAspectRatio: true,
                  onPostSelected: (post) {
                    final homeController = Get.find<HomeController>();
                    showPostBottomSheet(post,
                        onDeletePost: () {
                          homeController.deletePost(post);
                          Get.back();
                        },
                        onPostEdited: (post) {
                          homeController.insertPost(post);
                          controller.post = post;
                          controller.update();
                        },
                        onBlockUser: () {},
                        onMovePost: (group) {
                          final controller = Get.find<GroupController>();
                          homeController.movePost(post, group);
                          try {
                            if (group != controller.group) {
                              controller.removePost(post);
                              Get.back();
                            }
                          } catch(_) {}
                        });
                  },
                  onCommentTap: () => controller.focusNode.requestFocus(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 70.0),
                  child: FlexibleTreeView<CommentModel?>(
                    nodes: controller.nodes,
                    showLines: false,
                    scrollable: false,
                    nodeWidth: Get.mediaQuery.size.width,
                    nodeItemBuilder: (context, node) {
                      return CommentWidget(
                        comment: node.data,
                        node: node,
                        onLike: (comment) {
                          controller.likeComment(comment);
                        },
                        onDelete: (comment) {
                          _deleteComment(controller, comment);
                        },
                        onReply: (comment) {
                          controller.setComment(comment, controller.post);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ));
    });
  }

  void _pickImage(CommentController controller) async {
    final image = (await ImagePickers.pickerPaths(
        showCamera: true, galleryMode: GalleryMode.image, selectCount: 1));
    if (image.isNotEmpty) {
      controller.addComment(controller.post, media: image.first.path);
    }
  }

  _sendComment(CommentController controller) async {
    FocusScope.of(context).unfocus();
    if (controller.commentController.text.isEmpty) {
      _pickImage(controller);
    } else {
      await controller.addComment(controller.post);
      controller.post.commentsNumber = (controller.post.commentsNumber  ?? 0)+1;
      Get.find<GroupController>().updatePost(controller.post);
    }
  }

  void _deleteComment(CommentController controller, CommentModel comment) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Alert'),
              content: const Text('Do you want to delete your comment?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No')),
                TextButton(
                    onPressed: () async {
                      controller.deleteComment(comment, controller.post);
                      controller.post.commentsNumber = (controller.post.commentsNumber  ?? 0)-1;
                      Get.find<GroupController>().updatePost(controller.post);
                      Get.find<GroupController>().update();
                      controller.initializeCommentsNodes(controller.post);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes')),
              ],
            ));
  }

  void _showErrorDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Error auccured while getting the post'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.back(closeOverlays: true);
                    },
                    child: const Text('Ok'))
              ],
            ));
  }

  Future<void> _getPost(CommentController controller) async {
    try {
      await controller.getPost();
    } catch (e) {
      _showErrorDialog();
    }
  }
}
