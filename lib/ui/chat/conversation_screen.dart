import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_haptic/haptic.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qatar_speed/controllers/chat_controller.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/conversation.dart';
import 'package:qatar_speed/models/message.dart';
import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/notifications/notifications_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:voice_message_package/voice_message_package.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen(
      {Key? key, required this.conversation, this.isRequest = false})
      : super(key: key);

  final ConversationModel conversation;
  final bool isRequest;

  @override
  createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with RouteAware, RouteObserverMixin {
  //final List<types.Message> _messages = [];
  final _showSend = false.obs;
  final _showEmojies = false.obs;
  final _messageController = TextEditingController();
  late StreamSubscription<bool> _keyboardEventSubscription;
  bool _micPermitted = false;
  bool _isRecording = false;
  late String _currentRecordFileName;
  FlutterAudioRecorder2? _recorder;
  Timer? _recordingTimer;
  late ChatController _chatController;
  late StreamSubscription _firebaseListener;

  @override
  void initState() {
    super.initState();
    Res.chatScreenLevel = ChatScreenLevel.conversation;
    _initAppBar();
    _chatController = Get.find<ChatController>();
    _chatController.page = 0;
    _chatController.canLoadMore = true;
    _chatController.isLoadingMore = false;
    _chatController
      ..getMessages(widget.conversation)
      ..isFetching = true;
    _chatController.scrollController.addListener(_scrollListener);
    _keyboardEventSubscription =
        KeyboardVisibilityController().onChange.listen((event) {
      if (event) _showEmojies.value = false;
    });
    _checkMicPermission();
    _initFirebase();
  }

  void _initAppBar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.showAppBar.value = true;
      Res.titleWidget.value = _titleWidget();
      Res.scrollController.value = ScrollController();
      Res.appBarActions.value = [
        InkWell(
            onTap: () => Get.to(() => const NotificationsScreen()),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Obx(() {
                int count = 0;
                Get.find<HomeController>().notifications.forEach((key, value) {
                  count += value.where((element) => !element.isRead).length;
                });
                return Badge(
                  badgeColor: Colors.red,
                  showBadge: count > 0,
                  badgeContent: Text(
                    count < 10 ? count.toString() : '!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900),
                  ),
                  child: SvgPicture.asset('assets/ic_notif.svg'),
                );
              }),
            )),
      ];
    });
  }

  void _switchAppBarActions({bool isSelecting = false}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isSelecting) {
        Res.appBarActions.value = [
          InkWell(
              onTap: _showDeleteMessagesDialog,
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
              )),
          InkWell(
              onTap: () => _chatController.clearSelection(widget.conversation),
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              )),
        ];
      } else {
        Res.appBarActions.value = [
          InkWell(
              onTap: () => Get.to(() => const NotificationsScreen()),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Obx(() {
                  int count = 0;
                  Get.find<HomeController>()
                      .notifications
                      .forEach((key, value) {
                    count += value.where((element) => !element.isRead).length;
                  });
                  return Badge(
                    badgeColor: Colors.red,
                    showBadge: count > 0,
                    badgeContent: Text(
                      count < 10 ? count.toString() : '!',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900),
                    ),
                    child: SvgPicture.asset('assets/ic_notif.svg'),
                  );
                }),
              )),
        ];
      }
    });
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppBar();
    _chatController.isSelectingMessages = false;
  }

  @override
  void didPush() {
    super.didPush();
    _chatController.isSelectingMessages = false;
    _initAppBar();
  }

  @override
  void dispose() {
    super.dispose();
    _chatController.scrollController.removeListener(_scrollListener);
    _keyboardEventSubscription.cancel();
    Res.chatScreenLevel = ChatScreenLevel.list;
    _firebaseListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showEmojies.value) {
          _showEmojies.value = false;
          return false;
        }
        if (_chatController.isSelectingMessages) {
          _chatController.clearSelection(widget.conversation);
          return false;
        }
        return true;
      },
      child: Scaffold(
          body: GetBuilder<ChatController>(
              id: 'messages',
              builder: (controller) {
                _switchAppBarActions(
                    isSelecting: controller.isSelectingMessages);
                return AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Expanded(
                          child: Stack(
                        children: [
                          Positioned.fill(
                              child: Image.asset(
                            'assets/chat_bg.png',
                            fit: BoxFit.cover,
                          )),
                          if (controller.isFetching)
                            const Positioned.fill(
                                child: Center(
                              child: Text(
                                'Loading conversation...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'arial', color: Colors.grey),
                              ),
                            ))
                          else if (widget.conversation.messages?.isEmpty ??
                              true)
                            const Positioned.fill(
                                child: Center(
                              child: Text(
                                'No messages yet',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'arial', color: Colors.grey),
                              ),
                            ))
                          else
                            ListView.builder(
                              controller: controller.scrollController,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              itemCount:
                                  (widget.conversation.messages?.length ?? 0) +
                                      1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Text(
                                    'Loading...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey.withOpacity(
                                            controller.isLoadingMore
                                                ? 1.0
                                                : .0),
                                        fontFamily: 'arial'),
                                  );
                                }
                                return _chatItem(controller, index - 1);
                              },
                            )
                        ],
                      )),
                      if (controller.isRequests)
                        _requestActions(controller)
                      else
                        _messageBox(controller),
                    ],
                  ),
                );
              })),
    );
  }

  Widget _titleWidget() {
    return Row(
      children: [
        InkWell(
            onTap: () => Get.back(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
                color: Colors.black,
              ),
            )),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.transparent, width: 1.5),
              color: Colors.transparent),
          padding: const EdgeInsets.all(1.0),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.conversation.user.photo ?? '',
              placeholder: (context, _) => ShimmerBox(
                width: Res.isPhone ? 45.0 : 45.0,
                height: Res.isPhone ? 45.0 : 45.0,
              ),
              errorWidget: (_, __, ___) => Container(
                width: Res.isPhone ? 45.0 : 45.0,
                height: Res.isPhone ? 45.0 : 45.0,
                color: Colors.black,
              ),
              width: Res.isPhone ? 45.0 : 45.0,
              height: Res.isPhone ? 45.0 : 45.0,
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
              widget.conversation.user.name ?? 'User',
              style: const TextStyle(
                  color: Color(0xff2D3F7B),
                  fontFamily: 'arial',
                  fontWeight: FontWeight.w900),
            ),
            const Text(
              /*'Typing ..'*/
              '',
              style: TextStyle(
                  color: Color(0xff0090FF),
                  fontFamily: 'neusa',
                  fontSize: 10.0),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _checkMicPermission() async {
    final permission = await Permission.microphone.status;
    _micPermitted = [PermissionStatus.granted, PermissionStatus.limited]
        .contains(permission);
  }

  Future<void> _requestMicPermission() async {
    final permission = await Permission.microphone.request();
    _micPermitted = [PermissionStatus.granted, PermissionStatus.limited]
        .contains(permission);
    if (permission == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  Widget _recordButton(ChatController controller) {
    return GestureDetector(
      onLongPressDown: (_) {
        debugPrint('down');
        _isRecording = true;
        _record(controller);
      },
      onLongPressEnd: (_) {
        debugPrint('end');
        _isRecording = false;
        _stopRecording(controller);
      },
      onLongPressCancel: () {
        debugPrint('canceled');
        _isRecording = false;
        _cancelRecording();
      },
      child: SimpleTooltip(
        borderColor: Colors.transparent,
        content: Material(
            color: Colors.transparent,
            child: Text(
              controller.recordStatus.value,
              textAlign: TextAlign.center,
            )),
        show: _isRecording,
        minWidth: Get.mediaQuery.size.width * .3,
        ballonPadding: const EdgeInsets.all(10.0),
        tooltipDirection: TooltipDirection.up,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          height: 40.0,
          width: 40.0,
          padding: const EdgeInsets.all(8.0),
          child: const Center(
            child: Icon(
              Icons.mic,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _record(ChatController controller) async {
    if (!_micPermitted) {
      await _requestMicPermission();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('finished    $_isRecording');
    if (_isRecording) {
      unawaited(Haptic.onSelection());
      controller.setRecordMessage('initializing...\nplease wait');

      final path = (await getTemporaryDirectory()).path;
      _currentRecordFileName =
          '$path/${Get.find<UserController>().user.id}_${DateTime.now().millisecondsSinceEpoch}.mp3';
      _recorder = FlutterAudioRecorder2(_currentRecordFileName,
          audioFormat: AudioFormat.WAV);
      await _recorder?.initialized;
      debugPrint('initialized');

      _recorder?.start();
      debugPrint('started recording');
      _recorder?.current().then((current) {
        final now = DateTime.now();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final duration = DateTime.now().difference(now);
          final message =
              '${duration.inMinutes}:${duration.inSeconds.remainder(60)}';
          debugPrint('recording  $duration');
          controller.setRecordMessage(message);
        });
      });
    }
  }

  Future<void> _stopRecording(ChatController controller) async {
    debugPrint('stopping record...');
    final path = await _cancelRecording();
    debugPrint('record stopped  $path');
    unawaited(Haptic.onSuccess());
    controller.sendMessage(
      message: MessageModel(
          id: -1, fromId: Get.find<UserController>().user.id, media: path),
      conversation: widget.conversation,
    );
  }

  Future<String?> _cancelRecording() async {
    _isRecording = false;
    _recordingTimer?.cancel();
    return (await _recorder?.stop())?.path;
  }

  Future<void> _sendImage(ChatController controller) async {
    final photo = (await ImagePickers.pickerPaths(
            selectCount: 1, showCamera: true, galleryMode: GalleryMode.image))
        .first
        .path;

    if (photo != null) {
      controller.sendMessage(
          message: MessageModel(
              id: -1, fromId: Get.find<UserController>().user.id, media: photo),
          conversation: widget.conversation);
    }
  }

  Widget _messageBox(ChatController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Obx(() {
            return Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999.0),
                      color: const Color(0xFFB1B1B1).withOpacity(0.12),
                      border: Border.all(
                        width: 1.0,
                        color: const Color(0xFF2D3F7B).withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                        child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                          fontFamily: 'arial',
                          fontSize: Res.isPhone ? 14.0 : 17.0),
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (String txt) {
                        _showSend.value = txt.isNotEmpty;
                      },
                      decoration: InputDecoration(
                          isDense: false,
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                              fontFamily: 'arial',
                              color: const Color(0xffBABABA),
                              fontSize: Res.isPhone ? 14.0 : 17.0),
                          border: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () {
                              _sendImage(controller);
                            },
                            icon: const Icon(Icons.camera_alt),
                          ),
                          prefixIcon: IconButton(
                            onPressed: () {
                              _showEmojies.value = !_showEmojies.value;
                              if (KeyboardVisibilityController().isVisible &&
                                  _showEmojies.value) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                            icon: const Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey,
                            ),
                          )),
                    )),
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                if (_showSend.value)
                  _sendButton(controller)
                else
                  _recordButton(controller),
                const Spacer(),
              ],
            );
          }),
        ),
        Obx(() {
          return Offstage(
            offstage: !_showEmojies.value,
            child: LimitedBox(
              maxHeight: 200.0,
              child: EmojiPicker(
                  textEditingController: _messageController,
                  onBackspacePressed: () {
                    if (_messageController.text.isEmpty) {
                      _showSend.value = false;
                    }
                  },
                  onEmojiSelected: (_, __) {
                    _showSend.value = true;
                  },
                  config: Config(
                      columns: 7,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      gridPadding: EdgeInsets.zero,
                      initCategory: Category.RECENT,
                      bgColor: const Color(0xFFF2F2F2),
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      progressIndicatorColor: Colors.blue,
                      backspaceColor: Colors.blue,
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      showRecentsTab: true,
                      recentsLimit: 28,
                      replaceEmojiOnLimitExceed: false,
                      noRecents: const Text(
                        'No Recents',
                        style: TextStyle(fontSize: 20, color: Colors.black26),
                        textAlign: TextAlign.center,
                      ),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL)),
            ),
          );
        })
      ],
    );
  }

  Widget _chatItem(ChatController controller, int index) {
    final conversation = widget.conversation;
    final message = conversation.messages![index];
    final fromMe = message.fromId == Get.find<UserController>().user.id;

    final isImage =
        (mime((message.media?.split('/').last) ?? '')?.contains('image') ??
            false);
    final isAudio =
        (mime((message.media?.split('/').last) ?? '')?.contains('audio') ??
            false);
    if (message.text == null &&
        ((message.media ?? '').isEmpty || message.media == null)) {
      return Container();
    } else {
      return GestureDetector(
        onLongPress: message.status == SentStatus.sent && fromMe
            ? () {
                controller.selecteMessage(
                    message: message, conversation: conversation);
                unawaited(Haptic.onSelection());
              }
            : null,
        onTap: controller.isSelectingMessages &&
                message.status == SentStatus.sent &&
                fromMe
            ? () {
                controller.selecteMessage(
                    message: message, conversation: conversation);
              }
            : null,
        child: Container(
          color: Colors.green.withOpacity(message.selected ? .5 : .0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Bubble(
                  margin: const BubbleEdges.symmetric(vertical: 5),
                  padding: BubbleEdges.all((isImage || isAudio) &&
                          message.text == null &&
                          message.status != SentStatus.deleted
                      ? .0
                      : 8),
                  alignment: fromMe ? Alignment.topRight : Alignment.topLeft,
                  nip: (conversation.messages!.length > index + 1 &&
                              (conversation.messages?[index + 1].fromId ==
                                  message.fromId)) ||
                          isImage &&
                              message.text == null &&
                              message.status != SentStatus.deleted
                      ? BubbleNip.no
                      : fromMe
                          ? BubbleNip.rightBottom
                          : BubbleNip.leftBottom,
                  color: fromMe
                      ? const Color.fromRGBO(225, 255, 199, 1.0)
                      : Colors.white,
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    alignment: WrapAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(
                              left: message.media != null ? 0 : 3,
                              right: message.media != null ? 0 : 8),
                          child: message.status == SentStatus.deleted
                              ? const Text(
                                  'Deleted message',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'arial',
                                      fontWeight: FontWeight.w900),
                                )
                              : message.text != null
                                  ? Text(
                                      message.text ?? '',
                                      textAlign: fromMe
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: 'arial',
                                          color: fromMe &&
                                                  message.status ==
                                                      SentStatus.sending
                                              ? Colors.grey
                                              : Colors.black),
                                    )
                                  : isAudio
                                      ? IgnorePointer(
                                          ignoring: controller
                                                  .isSelectingMessages ||
                                              message.status != SentStatus.sent,
                                          child: Stack(
                                            children: [
                                              VoiceMessage(
                                                audioSrc: (message.media ?? ''),
                                                me: fromMe,
                                                noiseCount: 3,
                                                meFgColor: Colors.black,
                                                mePlayIconColor: Colors.white,
                                                contactBgColor: Colors.white,
                                                contactFgColor: Colors.black,
                                                contactPlayIconColor:
                                                    Colors.white,
                                                meBgColor: const Color.fromRGBO(
                                                    225, 255, 199, 1.0),
                                              ),
                                              if (message.status ==
                                                  SentStatus.sending) ...[
                                                Positioned.fill(
                                                    child: Container(
                                                        color: Colors.white
                                                            .withOpacity(message
                                                                        .status !=
                                                                    SentStatus
                                                                        .sent
                                                                ? .5
                                                                : .0))),
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              ]
                                            ],
                                          ),
                                        )
                                      : IgnorePointer(
                                          ignoring:
                                              controller.isSelectingMessages,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: InkWell(
                                              onTap: message.status ==
                                                      SentStatus.sent
                                                  ? () => showImageViewer(
                                                      context,
                                                      CachedNetworkImageProvider(
                                                          message.media!))
                                                  : null,
                                              child: CachedNetworkImage(
                                                imageUrl: message.media ?? '',
                                                fit: BoxFit.cover,
                                                placeholder: (context, _) =>
                                                    const ShimmerBox(
                                                  width: 200.0,
                                                  height: 200.0,
                                                ),
                                                errorWidget: (_, __, ___) {
                                                  debugPrint(
                                                      'message status  ${message.status}');
                                                  if (message.status ==
                                                      SentStatus.sending) {
                                                    return Stack(
                                                      children: [
                                                        Image.file(
                                                          File(message.media ??
                                                              ''),
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Positioned.fill(
                                                            child: Container(
                                                          color: Colors.white
                                                              .withOpacity(.5),
                                                        )),
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator())
                                                      ],
                                                    );
                                                  }
                                                  return const Icon(
                                                      Icons.broken_image);
                                                },
                                                width: 200.0,
                                                height: 200.0,
                                              ),
                                            ),
                                          ),
                                        )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            DateTime.now()
                                        .difference(message.createdAt!)
                                        .inHours <
                                    24
                                ? '${message.createdAt!.hour}:${message.createdAt!.minute}'
                                : timeago.format(message.createdAt!),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          if (fromMe)
                            Icon(
                              Icons.done_all,
                              color: (message.seen ?? false)
                                  ? Colors.green
                                  : Colors.grey,
                              size: 12,
                            )
                        ],
                      ),
                    ],
                  )),
              if (fromMe && message.status == SentStatus.failed)
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: const TextSpan(children: [
                        WidgetSpan(
                            child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 15.0,
                        )),
                        TextSpan(
                          text: 'failed to send, tap to resend',
                          style:
                              TextStyle(color: Colors.red, fontFamily: 'arial'),
                        ),
                      ]),
                    ),
                  ),
                )
            ],
          ),
        ),
      );
    }
  }

  void _scrollListener() {
    if (_chatController.scrollController.position.pixels < 30.0) {
      _chatController.getMessages(widget.conversation);
    }
  }

  void _showDeleteMessagesDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete'),
              content: const Text('Do you want to delete selected messages?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      _chatController.deleteSelected(widget.conversation);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes'))
              ],
            ));
  }

  Widget _sendButton(ChatController controller) {
    return GestureDetector(
      onTap: () {
        final msg = MessageModel(
            fromId: Get.find<UserController>().user.id,
            id: -1,
            text: _messageController.text);
        _messageController.text = '';
        _showSend.value = false;
        controller.sendMessage(message: msg, conversation: widget.conversation);
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        width: 40.0,
        height: 40.0,
        padding: const EdgeInsets.all(8.0),
        child: const Center(
          child: Icon(
            Icons.send,
            color: Colors.white,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  void _initFirebase() {
    _firebaseListener = FirebaseMessaging.onMessage.listen((msg) {
      if (msg.data.get('type') ==
              'chat' /*&&
          msg.data.get('coversation_id') == widget.conversation.id*/
          ) {
        if (msg.data.containsKey('seen')) {
          Get.find<ChatController>().seenMessage(
              int.parse(msg.data['message_id'].toString()),
              widget.conversation);
        } else {
          Get.find<ChatController>()
              .getMessageById(int.parse(msg.data['message_id'].toString()),
                  widget.conversation)
              .then((value) {
            if (Res.chatScreenLevel == ChatScreenLevel.conversation) {
              FlutterRingtonePlayer.play(fromAsset: 'assets/sounds/notif.mp3');
            }
          });
        }
      }
    });

    /* FirebaseMessaging.onBackgroundMessage((msg) async {
      if (msg.data.get('type') == 'chat' */ /*&&
          msg.data.get('coversation_id') == widget.conversation.id*/ /*) {
        Get.find<ChatController>()
            .getMessageById(int.parse(msg.data['message_id'].toString()), widget.conversation).then((value) {
          if (Res.chatScreenLevel == ChatScreenLevel.conversation) {
            FlutterRingtonePlayer.play(
                fromAsset: 'assets/sounds/notif.mp3');
          }
        });
      }
    });*/
  }

  Widget _requestActions(ChatController controller) {
    final key = GlobalKey();
    return Container(
      color: Colors.black54,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextButton(
                key: key,
                onPressed: () {
                  _showDialog(
                      title: 'Delete',
                      content: 'Do you want to delete this conversation?',
                      onTap: () async {
                        await controller
                            .deleteConversation(widget.conversation);
                        Get.back();
                      });
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 16),
                )),
          ),
          Container(
            width: .8,
            height: 25,
            color: Colors.white,
          ),
          Expanded(
            child: TextButton(
                onPressed: () {
                  _showDialog(
                      title: 'Block',
                      content:
                          'Do you want to block ${widget.conversation.user.name}?',
                      onTap: () async {
                        await Get.find<HomeController>()
                            .blockUser(widget.conversation.user);
                        Get.back();
                      });
                },
                child: const Text(
                  'Block',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 16),
                )),
          ),
          Container(
            width: .8,
            height: 25,
            color: Colors.white,
          ),
          Expanded(
            child: TextButton(
                onPressed: () {
                  controller.acceptConversation(widget.conversation);
                },
                child: const Text(
                  'Accept',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 16),
                )),
          ),
        ],
      ),
    );
  }

  void _showDialog({
    required String title,
    required String content,
    required Future<void> Function() onTap,
  }) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      onTap().then((value) => Navigator.pop(context));
                    },
                    child: const Text('Yes')),
              ],
            ));
  }
}
