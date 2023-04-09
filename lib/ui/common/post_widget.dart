import 'dart:async';
import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/file.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/ui/common/read_more.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/edit_post/edit_post.dart';
import 'package:qatar_speed/ui/posts/post_screen.dart';
import 'package:qatar_speed/ui/profile/profile_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../models/user.dart';
import '../../tools/res.dart';

class PostWidget extends StatefulWidget {
  const PostWidget(
      {Key? key,
      required this.post,
      this.onPostSelected,
      this.canTapUser = true,
      this.useAspectRatio = false,
      this.onCommentTap})
      : super(key: key);
  final PostModel post;
  final Function(PostModel)? onPostSelected;
  final bool canTapUser;
  final bool useAspectRatio;
  final Function()? onCommentTap;

  @override
  createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: !widget.canTapUser
                    ? null
                    : () => Get.to(() => ProfileScreen(
                          user: widget.post.user,
                        )),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (widget.onPostSelected != null) {
                                    widget.onPostSelected!(widget.post);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.more_horiz,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text:
                                            (widget.post.user?.name ?? "User"),
                                        style: TextStyle(
                                            fontFamily: 'arial',
                                            height: .9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                            fontSize: Res.isPhone ? 15 : 19.0),
                                      ),
                                      if (widget.post.originalPost != null) ...[
                                        TextSpan(
                                          text: ' shared ',
                                          style: TextStyle(
                                              fontFamily: 'arial',
                                              height: .9,
                                              color: Colors.black,
                                              fontSize:
                                                  Res.isPhone ? 15 : 19.0),
                                        ),
                                        WidgetSpan(
                                          child: InkWell(
                                            onTap: () =>
                                                Get.to(() => ProfileScreen(
                                                      user: widget.post
                                                          .originalPost!.user,
                                                    )),
                                            child: Text(
                                              widget.post.originalPost!.user!
                                                      .name ??
                                                  'User',
                                              style: TextStyle(
                                                  fontFamily: 'arial',
                                                  height: .9,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize:
                                                      Res.isPhone ? 15 : 19.0),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' post',
                                          style: TextStyle(
                                              fontFamily: 'arial',
                                              height: .9,
                                              color: Colors.black,
                                              fontSize:
                                                  Res.isPhone ? 15 : 19.0),
                                        ),
                                      ],
                                    ])),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                widget.post.createdAt == null
                                    ? ''
                                    : timeago.format(
                                        widget.post.createdAt!,
                                      ),
                                style: TextStyle(
                                    fontFamily: 'arial',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: Res.isPhone ? 12.0 : 15.0),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                (widget.post.user?.type ?? UserType.Moderator)
                                    .name,
                                style: TextStyle(
                                    fontFamily: 'arabic',
                                    color:
                                        widget.post.user?.color ?? Colors.black,
                                    fontSize: Res.isPhone ? 13.0 : 17.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      foregroundDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.transparent, width: 1.0)),
                      child: ClipOval(
                          child: CachedNetworkImage(
                        imageUrl: widget.post.user?.photo ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, _) => ShimmerBox(
                          width: Res.isPhone ? 70.0 : 70.0,
                          height: Res.isPhone ? 70.0 : 70.0,
                        ),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                        width: Res.isPhone ? 70.0 : 70.0,
                        height: Res.isPhone ? 70.0 : 70.0,
                      )),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        GestureDetector(
          onTap: () => Get.to(() => PostScreen(post: widget.post)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.post.text != null) ...[
                const SizedBox(
                  height: 8.0,
                ),
                AnimatedSize(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: ReadMoreText(
                                widget.post.text ?? ' ',
                                trimLines: 3,
                                onLinkTap: (link) {
                                  launchUrl(Uri.parse(link));
                                },
                                trimExpandedText: '\nshow less',
                                lessStyle: TextStyle(
                                    fontFamily: 'arial',
                                    fontSize: Res.isPhone ? 12.0 : 16.0,
                                    fontWeight: FontWeight.w900),
                                style: TextStyle(
                                    fontFamily: 'arial',
                                    fontSize: Res.isPhone ? 12.0 : 16.0),
                                textAlign: TextAlign.start,
                                trimMode: TrimMode.line,
                                moreStyle: TextStyle(
                                    fontFamily: 'arial',
                                    fontSize: Res.isPhone ? 12.0 : 16.0,
                                    fontWeight: FontWeight.w900),
                              )),
                        ],
                      ),
                    )),
              ],
              if (widget.post.originalPost?.text != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSize(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          children: [
                            SizedBox(
                                width: double.infinity,
                                child: ReadMoreText(
                                  widget.post.originalPost!.text!,
                                  trimLines: 3,
                                  trimExpandedText: '\nshow less',
                                  lessStyle: TextStyle(
                                      fontFamily: 'arial',
                                      fontSize: Res.isPhone ? 12.0 : 16.0,
                                      fontWeight: FontWeight.w900),
                                  style: TextStyle(
                                      fontFamily: 'arial',
                                      fontSize: Res.isPhone ? 12.0 : 16.0),
                                  textAlign: TextAlign.start,
                                  trimMode: TrimMode.line,
                                  moreStyle: TextStyle(
                                      fontFamily: 'arial',
                                      fontSize: Res.isPhone ? 12.0 : 16.0,
                                      fontWeight: FontWeight.w900),
                                )),
                          ],
                        ),
                      )),
                ),
              ],
              if ((widget.post.originalPost?.media ?? widget.post.media)
                  .isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(
                      widget.post.originalPost != null ? 8.0 : .0),
                  child: MasonryGridView.builder(
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ((widget.post.originalPost?.media ??
                                      widget.post.media)
                                  .length) >
                              1
                          ? 2
                          : 1,
                    ),
                    itemBuilder: (context, index) {
                      final photos =
                          widget.post.originalPost?.media ?? widget.post.media;
                      if (Res.isVideo(photos[0].file) ?? false) {
                        return _VideoView(
                          url: photos[0].file,
                          useAspectRatio: widget.useAspectRatio,
                        );
                      }
                      return _ImageView(photos: photos, index: index);
                    },
                    itemCount: min(
                        3,
                        (widget.post.originalPost?.media ?? widget.post.media)
                            .length),
                    shrinkWrap: true,
                    crossAxisSpacing: 3.0,
                    mainAxisSpacing: 3.0,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ),
              if ((widget.post.polls.length) > 1)
                Padding(
                  padding: EdgeInsets.all(
                      widget.post.originalPost != null ? 8.0 : .0),
                  child: FlutterPolls(
                      pollId: (widget.post.originalPost ?? widget.post)
                          .id
                          .toString(),
                      onVoted:
                          (PollOption pollOption, int newTotalVotes) async {
                        setState(() {
                          unawaited(Get.find<HomeController>().votePoll(
                              pollOption.id!,
                              (widget.post.originalPost ?? widget.post)));
                        });
                        return true;
                      },
                      userVotedOptionId:
                          (widget.post.originalPost ?? widget.post).votedPoll,
                      hasVoted:
                          (widget.post.originalPost ?? widget.post).votedPoll !=
                              null,
                      votedAnimationDuration: 500,
                      pollTitle: Container(),
                      pollOptions: (widget.post.originalPost ?? widget.post)
                          .polls
                          .map((e) => PollOption(
                              id: e.id,
                              title: Text(e.text),
                              votes: (e.votes ?? []).length))
                          .toList()),
                ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, bottom: 10.0, left: 5.0),
                child: GetBuilder<HomeController>(builder: (controller) {
                  return Text(
                    '${widget.post.commentsNumber ?? 0} comments .  ${widget.post.shares ?? 0} shares',
                    style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: Res.isPhone ? 11.0 : 15.0),
                  );
                }),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GetBuilder<HomeController>(builder: (controller) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton(
                    icon:
                        'ic_like${(widget.post.isLiked ?? false) ? 'd' : ''}.svg',
                    text: widget.post.likes?.toString() ?? '0',
                    onTap: () => controller.likePost(widget.post)),
                if (widget.post.canComment ?? false) ...[
                  _actionButton(
                      icon: 'comment.svg',
                      text: '${widget.post.commentsNumber} comment ',
                      onTap: () => widget.onCommentTap != null
                          ? widget.onCommentTap!()
                          : Get.to(() => PostScreen(
                                post: widget.post,
                                toComment: true,
                              ))),
                ],
                _actionButton(
                    icon: 'share-outline.svg',
                    text: 'share',
                    onTap: () {
                      Get.to(() => EditPostScreen(
                            sharingPost:
                                widget.post.originalPost ?? widget.post,
                          ))?.then((post) {
                        if (post != null) {
                          controller.sharePost(post).then((_) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Post has been shared"),
                            ));
                          });
                        }
                      });
                    }),
              ],
            );
          }),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            color: Colors.blueGrey,
            thickness: .5,
          ),
        ),
      ],
    );
  }

  _actionButton({required String icon, required String text, required onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/$icon',
              width: Res.isPhone ? 20.0 : 23.0,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: Res.isPhone ? 12.0 : 15.0,
                  color: Colors.black87),
            )
          ],
        ),
      ),
    );
  }
}

class _VideoView extends StatefulWidget {
  final String url;
  final bool useAspectRatio;

  const _VideoView({required this.url, required this.useAspectRatio});

  @override
  createState() => _VideoState();
}

class _VideoState extends State<_VideoView>
    with RouteAware, RouteObserverMixin {
  late final VideoPlayerController _playerController;
  final _position = .0.obs;
  final _showControls = false.obs;
  final _homeController = Get.find<HomeController>();

  @override
  void didPushNext() {
    super.didPush();
    _homeController.stopAllPlayers();
  }

  @override
  void didPop() {
    super.didPop();
    _homeController.stopAllPlayers();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playerController = VideoPlayerController.network(widget.url);
    _homeController.playerControllers.add(_playerController);
    _playerController.initialize().then((value) {
      setState(() {});
    });

    _playerController.addListener(_playerListener);
  }

  void _playerListener() {
    if (_playerController.value.isPlaying ||
        !_playerController.value.isPlaying) {
      setState(() {});
    }

    _position.value = _playerController.value.position.inMilliseconds + .0;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _playerController.removeListener(_playerListener);
    _playerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_playerController.value.isInitialized) {
      return Container(
        color: Colors.black,
        height: (Res.isPhone ? 222 : 350),
        width: double.infinity,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    return Stack(
      children: [
        if (_playerController.value.size.height >
                _playerController.value.size.width &&
            !widget.useAspectRatio)
          Container(
            color: Colors.black,
            child: Center(
              child: SizedBox(
                  height: _playerController.value.size.height >
                          _playerController.value.size.width
                      ? _playerController.value.size.height / 2.5
                      : _playerController.value.size.height,
                  width: _playerController.value.size.height >
                          _playerController.value.size.width
                      ? _playerController.value.size.width / 2.5
                      : _playerController.value.size.width,
                  child: VideoPlayer(_playerController)),
            ),
          )
        else
          AspectRatio(
            aspectRatio: _playerController.value.aspectRatio,
            child: VideoPlayer(_playerController),
          ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _playerController.value.isPlaying,
            child: GestureDetector(
              onTap: () {
                _homeController.stopAllPlayers();
                _playerController.play();
                _showControls.value = true;
                Timer(const Duration(seconds: 3),
                    () => _showControls.value = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _playerController.value.isPlaying
                    ? Colors.transparent
                    : Colors.black54,
                child: Center(
                  child: _playerController.value.isPlaying
                      ? Container()
                      : const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 90.0,
                        ),
                ),
              ),
            ),
          ),
        ),
        if (_playerController.value.isPlaying)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (!_showControls.value) {
                  _showControls.value = true;
                  Timer(const Duration(seconds: 3),
                      () => _showControls.value = false);
                }
              },
              child: Obx(() => AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showControls.value ? 1.0 : .0,
                    child: SizedBox(
                      width: Get.width,
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    _formatDuration(
                                        _playerController.value.position),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'arial',
                                        fontWeight: FontWeight.w100,
                                        fontSize: 10.0),
                                  ),
                                ),
                                Text(
                                  _formatDuration(
                                      _playerController.value.duration),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'arial',
                                      fontWeight: FontWeight.w100,
                                      fontSize: 10.0),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (_playerController.value.isPlaying) {
                                        _playerController.pause();
                                        _showControls.value = false;
                                      } else {
                                        _homeController.stopAllPlayers();
                                        _playerController.play();
                                        _showControls.value = true;
                                        Timer(const Duration(seconds: 3),
                                            () => _showControls.value = false);
                                      }
                                    },
                                    icon: Icon(
                                      _playerController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    )),
                                Expanded(
                                  child: FlutterSlider(
                                      values: [_position.value],
                                      onDragging: (_, pos, __) {
                                        _playerController.seekTo(Duration(
                                            milliseconds: pos.toInt()));
                                      },
                                      handler: FlutterSliderHandler(
                                        child: Container(),
                                      ),
                                      handlerHeight: 15.0,
                                      handlerWidth: 15.0,
                                      tooltip:
                                          FlutterSliderTooltip(format: (txt) {
                                        final duration = Duration(
                                            milliseconds:
                                                double.parse(txt).toInt());
                                        return _formatDuration(duration);
                                      }),
                                      trackBar: FlutterSliderTrackBar(
                                        activeTrackBar: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        inactiveTrackBar: BoxDecoration(
                                            color: Colors.white38,
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                      ),
                                      min: .0,
                                      max: _playerController
                                              .value.duration.inMilliseconds +
                                          .0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String str = duration.toString().split('.').first.padLeft(8, "0");
    return str.substring(3);
  }
}

class _ImageView extends StatelessWidget {
  final List<FileModel> photos;
  final int index;

  const _ImageView({required this.photos, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        MultiImageProvider multiImageProvider = MultiImageProvider(photos
            .map((e) => CachedNetworkImageProvider(
                  e.file,
                ))
            .toList());

        showImageViewerPager(context, multiImageProvider,
            onPageChanged: (page) {},
            onViewerDismissed: (page) {},
            immersive: false,
            useSafeArea: true);
      },
      child: Stack(
        children: [
          Container(
              foregroundDecoration: BoxDecoration(
                  color: (index > 1 && (photos.length) > 3)
                      ? Colors.black.withOpacity(.6)
                      : Colors.transparent),
              child: CachedNetworkImage(
                imageUrl: photos[index].file,
                placeholder: (context, _) => ShimmerBox(
                  width: double.infinity,
                  height: index == 0
                      ? (Res.isPhone ? 222 : 350)
                      : (index > 0 && photos.length == 2)
                          ? (Res.isPhone ? 222 : 350)
                          : (Res.isPhone ? 110 : 173.5),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: double.infinity,
                  height: index == 0
                      ? (Res.isPhone ? 222 : 350)
                      : (index > 0 && photos.length == 2)
                          ? (Res.isPhone ? 222 : 350)
                          : (Res.isPhone ? 110 : 173.5),
                  color: Colors.black,
                ),
                width: double.infinity,
                height: index == 0
                    ? (Res.isPhone ? 222 : 350)
                    : (index > 0 && photos.length == 2)
                        ? (Res.isPhone ? 222 : 350)
                        : (Res.isPhone ? 110 : 173.5),
                fit: BoxFit.cover,
              )),
          if (index > 1 && photos.length > 3)
            Positioned.fill(
                child: Center(
                    child: Text(
              '+${photos.length - 3} more',
              style: const TextStyle(color: Colors.white),
            )))
        ],
      ),
    );
  }
}
