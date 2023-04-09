import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/group_controller.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/comment.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/services/posts.dart';
import 'package:qatar_speed/ui/common/tree_view/src/tree_view_main.dart';

class CommentController extends GetxController {
  late final TextEditingController commentController;
  late final FocusNode focusNode;
  Map<String, List<String>> _commentsNodes = {'0': []};
  List<TreeNode<CommentModel?>> nodes = [];
  CommentModel? replyTo;

  late PostModel post;

  getPost() async {
    if (post.user != null) {
      return;
    }
    post = (await PostsWebService().getPosts(postId: post.id)).first;
    final controller = Get.find<HomeController>();
    int? index =
        controller.posts.indexWhere((element) => element.id == post.id);
    if (index > -1) {
      controller.posts.removeAt(index);
      controller.posts.insert(index, post);
      controller.update(['home_posts']);
    }
    update();
  }

  void setText(String txt) {
    commentController.text = txt;
    update();
  }

  void setComment(CommentModel comment, PostModel post) {
    removeReply();
    replyTo = comment;
    post.commentsNumber = post.commentsNumber! + 1;
    prefixText('@${comment.user?.name}');
    update();
    focusNode.requestFocus();
  }

  Future<void> addComment(PostModel post, {String? media}) async {
    String? text = commentController.text.replaceAll(' ', '').isNotEmpty
        ? commentController.text
        : null;
    commentController.text = '';
    CommentModel? reply = replyTo;
    removeReply();
    update();
    FocusNode().requestFocus();
    try {
      final comment = await PostsWebService().addComment(
          postId: post.id, text: text, media: media, parentId: reply?.id);
      if (reply != null) {
        reply.comments.add(comment);
      } else {
        post.comments.add(comment);
        Get.find<HomeController>().addComment(postId: post.id);
        Get.find<HomeController>().update();
        update();
      }
      initializeCommentsNodes(post);
    } on DioError catch (e) {
      debugPrint(e.response?.data ?? 'null data');
    } finally {
      if (media != null) {
        unawaited(File(media).delete());
      }
    }
  }

  void removeReply() {
    if (commentController.text.startsWith('@${replyTo?.user?.username} ')) {
      commentController.text = commentController.text
          .replaceFirst('@${replyTo?.user?.username} ', '');
    }
    replyTo = null;
    update();
  }

  void prefixText(String txt) {
    commentController.text = '$txt ${commentController.text}';
    update();
  }

  void _buildCommentsNodes(CommentModel comment, TreeNode parent) {
    if (comment.comments.isNotEmpty) {
      _commentsNodes[comment.id!.toString()] = [];
      for (var element in comment.comments) {
        _commentsNodes[comment.id.toString()]!.add(element.id!.toString());
        final node = TreeNode<CommentModel?>(data: element);
        _buildCommentsNodes(element, node);
        parent.addNode(node);
      }
    }
  }

  void initializeCommentsNodes(PostModel post) {
    _commentsNodes = {'0': []};
    nodes.clear();
    for (CommentModel element in post.comments) {
      _commentsNodes['0']!.add(element.id!.toString());
      final node = TreeNode<CommentModel?>(data: element);
      _buildCommentsNodes(element, node);
      nodes.add(node);
    }
    update();
  }

  bool _deleteComment(CommentModel comment, List<CommentModel> comments) {
    bool found = false;
    for (CommentModel cmt in comments) {
      if (cmt.comments.contains(comment)) {
        cmt.comments.remove(comment);
        return true;
      }
      found = _deleteComment(comment, cmt.comments);
      if (found) {
        return true;
      }
    }
    return found;
  }

  void deleteComment(CommentModel comment, PostModel post) {
    PostsWebService().deleteComment(comment).catchError((_) {});
    if (comment.parentId == null) {
      post.comments.remove(comment);
    } else {
      _deleteComment(
        comment,
        post.comments,
      );
    }
    update();
  }

  void likeComment(CommentModel comment) {
    unawaited(PostsWebService().toggleCommentLike(comment));
    comment.isLiked = !comment.isLiked;
    update(['comment_like']);
  }

  @override
  void onInit() {
    super.onInit();
    commentController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void onClose() {
    super.onClose();
    replyTo = null;
    setText('');
  }
}
