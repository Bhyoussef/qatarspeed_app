import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/comments_controller.dart';
import 'package:qatar_speed/models/comment.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/common/tree_view/src/tree_view_main.dart';
import 'package:qatar_speed/ui/profile/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../tools/res.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget(
      {Key? key,
      required this.comment,
      this.node,
      this.onReply,
      this.onDelete,
      this.onLike})
      : super(key: key);
  final CommentModel? comment;
  final TreeNode<CommentModel?>? node;
  final Function(CommentModel)? onReply;
  final Function(CommentModel)? onDelete;
  final Function(CommentModel)? onLike;

  @override
  createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late CommentModel _comment;

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) _comment = widget.comment!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: /* widget.comment == null
          ? Container(
              margin: EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999.0),
                  border: Border.all(color: Colors.blue)),
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Center(
                child: TextField(
                  onSubmitted: (_) {
                    widget.node?.parent?.removeNodeAt(0);
                  },
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 13.0,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      suffixIcon: InkWell(
                          onTap: () {
                            widget.node?.parent?.removeNodeAt(0);
                          },
                          child: Icon(
                            Icons.send,
                            color: Colors.blue,
                          ))),
                ),
              ),
            )
          :*/
            Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                foregroundDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellow, width: 1.0)),
                child: ClipOval(
                    child: CachedNetworkImage(
                  imageUrl: _comment.user?.photo ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, _) => ShimmerBox(
                    width: Res.isPhone ? 35.0 : 60.0,
                    height: Res.isPhone ? 35.0 : 60.0,
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                  width: Res.isPhone ? 35.0 : 60.0,
                  height: Res.isPhone ? 35.0 : 60.0,
                ))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: (widget.comment?.media != null &&
                              widget.comment!.media!.isNotEmpty)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      Get.to(() => const ProfileScreen()),
                                  child: Text(
                                    '${_comment.user?.username ?? _comment.user?.name ?? ''} ',
                                    style: TextStyle(
                                        fontFamily: 'arial',
                                        fontWeight: FontWeight.w900,
                                        fontSize: Res.isPhone ? 13.0 : 17.0),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: InkWell(
                                    onTap: () {
                                      showImageViewer(
                                          context,
                                          CachedNetworkImageProvider(
                                              widget.comment!.media!));
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: widget.comment!.media!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, _) => ShimmerBox(
                                        width: Res.isPhone ? 80.0 : 60.0,
                                        height: Res.isPhone ? 80.0 : 60.0,
                                      ),
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                      width: Res.isPhone ? 150.0 : 60.0,
                                      height: Res.isPhone ? 150.0 : 60.0,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(children: [
                                WidgetSpan(
                                  child: InkWell(
                                    onTap: () =>
                                        Get.to(() => const ProfileScreen()),
                                    child: Text(
                                      '${_comment.user?.name ?? ''} ',
                                      style: TextStyle(
                                          fontFamily: 'arial',
                                          fontWeight: FontWeight.w900,
                                          fontSize: Res.isPhone ? 13.0 : 17.0),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                    text: '${_comment.comment}',
                                    style: TextStyle(
                                        fontFamily: 'arial',
                                        color: Colors.black,
                                        fontSize: Res.isPhone ? 13.0 : 17.0))
                              ])),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        children: [
                          Text(
                            timeago.format(_comment.createdAt ?? DateTime.now()),
                            style: TextStyle(
                                fontFamily: 'arial',
                                color: Colors.grey,
                                fontWeight: FontWeight.w900,
                                fontSize: Res.isPhone ? 13.0 : 17.0),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          InkWell(
                            onTap: () => widget.onReply!(widget.comment!),
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                  fontFamily: 'arial',
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w900,
                                  fontSize: Res.isPhone ? 12.0 : 16.0),
                            ),
                          ),
                          if (widget.comment!.comments.isNotEmpty) ...[
                            InkWell(
                              onTap: () {
                                widget.node!.expanded = !widget.node!.expanded;
                              },
                              child: Text(
                                '${widget.comment!.comments.length} replies',
                                style: TextStyle(
                                    fontFamily: 'arial',
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w900,
                                    fontSize: Res.isPhone ? 12.0 : 16.0),
                              ),
                            ),
                          ],
                          if (widget.comment?.isMine ?? false) ...[

                            InkWell(
                              onTap: () => widget.onDelete!(widget.comment!),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                    fontFamily: 'arial',
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w900,
                                    fontSize: Res.isPhone ? 12.0 : 16.0),
                              ),
                            ),
                          ]
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => widget.onLike!(widget.comment!),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GetBuilder<CommentController>(
                  id: 'comment_like',
                  builder: (_) {
                    return Icon(
                      widget.comment!.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: Res.isPhone ? 25.0 : 35.0,
                      color: Colors.red,
                    );
                  },
                ),
              ),
            )
          ],
        )
        /*Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        foregroundDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.yellow, width: 1.0)),
                        child: ClipOval(
                            child: CachedNetworkImage(
                          imageUrl: _comment.user?.photo ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, _) => ShimmerBox(
                            width: Res.isPhone ? 35.0 : 60.0,
                            height: Res.isPhone ? 35.0 : 60.0,
                          ),
                          errorWidget: (_, __, ___) => Icon(Icons.broken_image),
                          width: Res.isPhone ? 35.0 : 60.0,
                          height: Res.isPhone ? 35.0 : 60.0,
                        ))),
                    Column(
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: InkWell(
                              onTap: () => Get.to(() => ProfileScreen()),
                              child: Text(
                                _comment.user?.nickName ?? '',
                                style: TextStyle(
                                    fontFamily: 'arial',
                                    fontWeight: FontWeight.w900,
                                    fontSize: Res.isPhone ? 13.0 : 17.0),
                              ),
                            ),
                          ),
                              TextSpan(
                                text: _comment.comment??''
                              ),
                        ],
                              style: TextStyle(
                                  fontFamily: 'arial',
                                  fontSize: Res.isPhone ? 13.0 : 17.0),
                            )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Text(
                                  timeago.format(_comment.createdAt??DateTime.now()),
                                style: TextStyle(
                                    fontFamily: 'arial',
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w900,
                                    fontSize: Res.isPhone ? 13.0 : 17.0),
                              ),

                            SizedBox(width: 20.0,),

                            Text(
                              'Reply',
                              style: TextStyle(
                                  fontFamily: 'arial',
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w900,
                                  fontSize: Res.isPhone ? 13.0 : 17.0),
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '7h',
                          style: TextStyle(
                              fontFamily: 'arial',
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: Res.isPhone ? 13.0 : 17.0),
                        )
                      ],
                    ),
                    Expanded(child: Container()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _comment.user?.nickName ?? "User",
                          style: TextStyle(
                              fontFamily: 'arial',
                              height: .9,
                              fontWeight: FontWeight.w900,
                              fontSize: Res.isPhone ? 15.0 : 19.0),
                        ),
                        Text(
                          (_comment.user?.type ?? UserType.Moderator)
                              .toString()
                              .split('.')
                              .last,
                          style: TextStyle(
                              fontFamily: 'arabic',
                              color:
                                  (_comment.user?.type ?? UserType.Moderator) ==
                                          UserType.Moderator
                                      ? Res.moderatorColor
                                      : (_comment.user?.type ??
                                                  UserType.Moderator) ==
                                              UserType.VIP
                                          ? Res.vipColor
                                          : Colors.black,
                              fontSize: Res.isPhone ? 13.0 : 17.0,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 5.0),
                  child: Column(
                    children: [
                      Text(
                        _comment.comment ?? '',
                        style: TextStyle(
                            fontFamily: 'arial',
                            fontSize: Res.isPhone ? 14.0 : 21.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.node != null)
                  Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: Res.isPhone ? 16.0 : 25.0,
                        ),
                        const SizedBox(
                          width: 3.0,
                        ),
                        Text(
                          '34 Likes',
                          style: TextStyle(
                              fontFamily: 'arial',
                              fontSize: Res.isPhone ? 13.0 : 17.0),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        InkWell(
                          onTap: () {
                            if (widget.node?.children
                                    .where((element) => element.data == null)
                                    .isEmpty ??
                                false) {
                              _removeAllEmptyReplies(
                                  _goToRootNode(widget.node!),
                                  collapseChildren: false);
                              widget.node?.insertNodeAt(
                                  0, TreeNode<CommentModel?>(data: null));
                              widget.node?.expanded = true;
                            } else
                              widget.node?.children.removeWhere(
                                  (element) => element.data == null);
                          },
                          child: Icon(
                            Icons.mode_comment_outlined,
                            size: Res.isPhone ? 16.0 : 25.0,
                          ),
                        ),
                        SizedBox(
                          width: 3.0,
                        ),
                        InkWell(
                            onTap: () {
                              widget.node?.expanded =
                                  !(widget.node?.expanded ?? false);
                              if (!(widget.node?.expanded ?? false))
                                _removeAllEmptyReplies(widget.node!);
                            },
                            child: Text(
                                '${_comment.comments?.length ?? 0} replies',
                                style: TextStyle(
                                    fontFamily: 'arial',
                                    fontSize: Res.isPhone ? 13.0 : 17.0))),
                      ],
                    ),
                  )
              ],
            )*/
        );
  }

  /*void _removeAllEmptyReplies(TreeNode node, {collapseChildren = true}) {
    node.children.removeWhere((element) => element.data == null);
    if (node.children != null) {
      for (int i = 0; i < node.children.length; i++) {
        _removeAllEmptyReplies(node.children[i],
            collapseChildren: collapseChildren);
        if (collapseChildren) node.expanded = false;
      }
    }
  }

  TreeNode _goToRootNode(TreeNode node) {
    TreeNode parent = node;
    if (node.parent != null) {
      parent = _goToRootNode(node.parent!);
    }
    return parent;
  }*/
}
