import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/chat_controller.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/conversation.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/chat/conversation_screen.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/notifications/notifications_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key, this.user}) : super(key: key);
  final UserModel? user;

  @override
  createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with RouteAware, RouteObserverMixin {
  late StreamSubscription _firebaseListener;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).unfocus();
      Get.find<ChatController>().getConversations(refresh: true);
    });
  }

  @override
  void didPush() {
    super.didPush();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void initState() {
    super.initState();
    Res.chatScreenLevel = ChatScreenLevel.list;
    Get.find<ChatController>().getConversations().then((value) {
      if (widget.user != null) {
        late ConversationModel conversation;
        try {
          conversation = Get.find<ChatController>()
              .conversations
              .firstWhere((element) => element.id == widget.user!.id);
        } catch (e) {
          conversation = ConversationModel(
              id: widget.user!.id, user: widget.user!, messages: []);
          Get.find<ChatController>().addConversation(conversation);
        } finally {
          Get.to(() => ConversationScreen(
                conversation: conversation,
              ));
        }
      }
    });
    _initAppbar();
    _initFirebase();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.gotMessages.value = false;
      Res.titleWidget.value = null;
      Res.appBarActions.value = [
        InkWell(
            onTap: () => Get.to(() => const NotificationsScreen()),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Obx(() {
                int count = 0;
                Get.find<HomeController>().notifications.forEach((key, value) {
                  count += value.where((element) => !element.isRead).length;
                });
                return Badge(
                  badgeColor: Colors.red,
                  showBadge: count > 0,
                  badgeContent: Text(count < 10 ? count.toString() : '!', style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900
                  ),),
                  child: SvgPicture.asset('assets/ic_notif.svg'),
                );
              }),
            )),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controller = Get.find<ChatController>();
        if (controller.isRequests) {
          controller.switchView();
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: Res.isPhone ? 15.0 : Get.mediaQuery.size.width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              _searchBox(),
              const SizedBox(
                height: 30.0,
              ),
              GetBuilder<ChatController>(
                  id: 'conversations',
                  builder: (controller) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _messagesActions(controller),
                          const Divider(),
                          controller.isFetchingConversations
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: (controller.searchConversations ??
                                          (controller.isRequests
                                              ? controller.requests
                                              : controller.conversations))
                                      .length,
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) =>
                                      const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30.0),
                                    child: Divider(),
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final conversation =
                                    (controller.searchConversations ??
                                            (controller.isRequests
                                                ? controller.requests
                                                : controller.conversations))[index];
                                    return Dismissible(
                                        key: Key(DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString()),
                                        onDismissed: (_) => _deleteConversation(
                                            conversation, controller, index),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                            color: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: const Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                            )),
                                        child: ConversationItem(
                                          controller: controller,
                                          conversation: conversation,
                                        ));
                                  },
                                )
                        ]);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Res.chatScreenLevel = ChatScreenLevel.none;
    _firebaseListener.cancel();
  }

  Widget _searchBox() {
    final controller = Get.find<ChatController>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999.0),
        color: const Color(0xFFB1B1B1).withOpacity(0.12),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFF2D3F7B).withOpacity(0.2),
        ),
      ),
      margin: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: TextField(
          style: TextStyle(
              fontFamily: 'arial', fontSize: Res.isPhone ? 14.0 : 17.0),
          textAlignVertical: TextAlignVertical.center,
          cursorHeight: 12.0,
          onChanged: (txt) => controller.filter(txt),
          decoration: InputDecoration(
              isDense: true,
              hintText: 'search',
              hintStyle: TextStyle(
                  fontFamily: 'arial',
                  fontWeight: FontWeight.w900,
                  fontSize: Res.isPhone ? 14.0 : 17.0),
              border: InputBorder.none,
              disabledBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              )),
        ),
      ),
    );
  }

  Widget _messagesActions(ChatController controller) {
    if (controller.isRequests || controller.requests.isEmpty) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: () => controller.switchView(requests: true),
      child: Badge(
        badgeContent: Text(
          controller.requests.length.toString(),
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
        ),
        showBadge: controller.requests.isNotEmpty,
        badgeColor: Colors.transparent,
        child: const Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            'Request messages',
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
        ),
      ),
    );
    /*return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.archive,
              color: Colors.blue,
              size: Res.isPhone ? 18.0 : 25.0,
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              'Archive',
              style: TextStyle(
                  fontFamily: 'neusa',
                  fontWeight: FontWeight.w100,
                  color: Colors.blue,
                  fontSize: Res.isPhone ? 12.0 : 16.0),
            ),
          ],
        )
      ],
    );*/
  }

  void _initFirebase() {
    _firebaseListener = FirebaseMessaging.onMessage.listen((msg) {
      if (((msg.data).get('type') ?? '') == 'chat') {
        Get.find<ChatController>().getConversations().then((value) {
          if (Res.chatScreenLevel == ChatScreenLevel.list) {
            FlutterRingtonePlayer.play(fromAsset: 'assets/sounds/notif.mp3');
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Res.gotMessages.value = false;
        });
      }
    });

    /*FirebaseMessaging.onBackgroundMessage((msg) async {
      if (msg.data != null) {
        if (((msg.data as Map).get('type') ?? '') == 'chat') {
          print(msg.data);
          Get.find<ChatController>().getConversations().then((value) {
            if (Res.chatScreenLevel == ChatScreenLevel.list) {
              FlutterRingtonePlayer.play(
                  fromAsset: 'assets/sounds/notif.mp3');
            }
          });
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Res.gotMessages.value = false;
          });
        }
      }
    });*/
  }

  _deleteConversation(
      ConversationModel conversation, ChatController controller, int index) {
    ScaffoldMessenger.of(Res.baseContext).showSnackBar(
      SnackBar(
          duration: const Duration(seconds: 3),
          content: Text('Deleting ${conversation.user.name} messages'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              conversation.delete = false;
              controller.insertConversation(conversation, index);
              ScaffoldMessenger.of(Res.baseContext).hideCurrentSnackBar();
            },
          )),
    );
    controller.deleteConversation(conversation);
  }
}

class ConversationItem extends StatelessWidget {
  final ConversationModel conversation;
  final ChatController controller;

  const ConversationItem(
      {super.key, required this.conversation, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ConversationScreen(
              conversation: conversation,
          isRequest: controller.isRequests,
            ))?.then((value) => controller.markMessageAsRead(conversation));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: [
              Container(
                width: 45.0,
                height: 45.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.0,
                    color: const Color(0xFF707070),
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: conversation.user.photo ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, _) => ShimmerBox(
                      width: Res.isPhone ? 45.0 : 60.0,
                      height: Res.isPhone ? 45.0 : 60.0,
                    ),
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                    width: Res.isPhone ? 45.0 : 60.0,
                    height: Res.isPhone ? 45.0 : 60.0,
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 1.0,
              //   right: 1.2,
              //   child: Container(
              //     width: 13.0,
              //     height: 13.0,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: const Color(0xFF00EE20),
              //       border: Border.all(
              //         width: 3.0,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  conversation.user.name ?? '',
                  style: const TextStyle(
                    fontFamily: 'neusa',
                    fontSize: 15.0,
                    color: Color(0xFF808080),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  timeago.format(conversation.createdAt),
                  style: const TextStyle(
                    fontFamily: 'arial',
                    fontSize: 14.0,
                    color: Color(0xFF808080),
                  ),
                ),
                Text(
                  (conversation.message?.containsKey('text') ?? false)
                      ? (conversation.message?['text'] ?? '').toString()
                      : (conversation.message?.containsKey('image') ?? false)
                          ? 'Sent an attachement'
                          : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'neusa',
                    fontSize: conversation.unread > 0 ? 12.0 : 14.0,
                    color: const Color(0xFF515C6F),
                    fontWeight: conversation.unread > 0
                        ? FontWeight.w900
                        : FontWeight.w100,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Column(
            children: <Widget>[
              Text(
                '9:20 AM',
                style: TextStyle(
                  fontFamily: 'arial',
                  fontSize: 14.0,
                  color: const Color(0xFF515C6F).withOpacity(0.5),
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(
                height: 10.0,
              ),
              if (conversation.unread > 0)
                SizedBox(
                  width: 18.9,
                  height: 27.0,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      Positioned(
                        bottom: 0,
                        child: SvgPicture.asset(
                          'assets/ic_chat_enabled.svg',
                          width: 18.9,
                          height: 17.0,
                        ),
                      ),
                      Positioned(
                        top: .0,
                        right: .0,
                        child: Text(
                          conversation.unread.toString(),
                          style: TextStyle(
                            fontFamily: 'neusa',
                            fontSize: 14.0,
                            color: const Color(0xFFBB0000),
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.16),
                                offset: const Offset(0, 2.0),
                                blurRadius: 2.0,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(
            width: 5.0,
          ),
          /*Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: InkWell(
              onTap: () {
                print('onTap Path 206');
              },
              child: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}
