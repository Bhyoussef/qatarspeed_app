import 'dart:io';

import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/profile_controller.dart';
import 'package:qatar_speed/tools/extensions.dart';
import 'package:qatar_speed/tools/getx_controllers_binding.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/about/about_screen.dart';
import 'package:qatar_speed/ui/chat/chat_list_screen.dart';
import 'package:qatar_speed/ui/home/home_screen.dart';
import 'package:qatar_speed/ui/market/market_screen.dart';
import 'package:qatar_speed/ui/members/members_screen.dart';
import 'package:qatar_speed/ui/profile/profile_screen.dart';
import 'package:qatar_speed/ui/search/search_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:qatar_speed/ui/notifications/notifications_screen.dart';


import 'custom_bottom_bar/navigation_bar.dart';
import 'custom_bottom_bar/navigation_bar_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageIndex = 0.obs;
  final _navigationKey = GlobalKey<NavigatorState>();
  DateTime _firstPress = DateTime.now();
  final _nestedKey = Get.nestedKey('nav_key');

  final _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const MarketScreen(),
    const MembersScreen(),
    const ProfileScreen(),
    const AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();

    Res.baseContext = context;
    Res.initSystemOverlays();
    Res.keyboardEventSubscription =
        KeyboardVisibilityController().onChange.listen((event) {
      Res.showBottomBar.value = !event;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<HomeController>().countMessages();
    });
    _initFirebase();
  }

  @override
  void dispose() {
    super.dispose();
    Get.find<HomeController>().close();
    Res.keyboardEventSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Obx(() {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: Obx(() {
              return Res.showBottomBar.value
                  ? CustomNavBar(
                      items: [
                        CustomNavBarItem(
                          icon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_tashometer.svg'),
                          tooltip: 'Home',
                          activeIcon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_tashometer_enabled.svg'),
                        ),
                        CustomNavBarItem(
                          icon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_search.svg'),
                          tooltip: 'Search',
                          activeIcon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_search_enabled.svg'),
                        ),
                        CustomNavBarItem(
                          icon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_shop.svg'),
                          tooltip: 'Market',
                          activeIcon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_shop_enabled.svg'),
                        ),
                        CustomNavBarItem(
                          icon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_grp.svg'),
                          tooltip: 'Groups',
                          activeIcon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_grp_enabled.svg'),
                        ),
                        CustomNavBarItem(
                          icon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_profile.svg'),
                          tooltip: 'My profile',
                          activeIcon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_profile_enabled.svg'),
                        ),
                        CustomNavBarItem(
                          icon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_about.svg'),
                          tooltip: 'About',
                          activeIcon: SvgPicture.asset(
                              'assets/bottom_nav_bar/ic_about_enabled.svg'),
                        ),
                      ],
                      indicatorColor: const Color(0xffEED600),
                      onTap: (index) async {
                        if (_pageIndex.value != index) {
                          _pageIndex.value = index;
                          if (Get.isRegistered<ProfileController>()) {
                            await Get.delete<ProfileController>();
                          }
                          Get.offAll(() => _screens[index]);
                        }
                      },
                      currentIndex: _pageIndex.value,
                    )
                  : Container(
                      height: .0,
                    );
            }),
            appBar: Res.showAppBar.value
                ? ScrollAppBar(
                    controller: Res.scrollController.value,
                    title: _buildTitle(),
                    titleSpacing: .0,
                    backgroundColor: Colors.white,
                    titleTextStyle: const TextStyle(color: Colors.black),
                    toolbarTextStyle: const TextStyle(color: Colors.black),
                    actions: _buildAppBarActions(),
                    automaticallyImplyLeading: false,
                  )
                : null,
            body: WillPopScope(
              onWillPop: () async {
                if (Navigator.canPop(Get.context!)) {
                  Navigator.maybePop(Get.context!);
                  return false;
                }

                if (Res.isHome.isFalse) {
                  if (!Navigator.canPop(Get.context!)) {
                    final popped = await Navigator.maybePop(Get.context!);
                    if (popped) {
                      return false;
                    }
                  }
                  _pageIndex.value = 0;
                  Get.offAll(() => _screens[0]);
                  Res.showAppBar.value = true;
                  return false;
                }

                final now = DateTime.now();

                if (now.difference(_firstPress).inMilliseconds > 800) {
                  _firstPress = now;
                  ScaffoldMessenger.of(Res.baseContext)
                      .showSnackBar(const SnackBar(
                    content: Text('Press back again to quit'),
                    duration: Duration(milliseconds: 800),
                  ));
                  return false;
                }
                // May be reject by appstore
                // MoveToBackground.moveTaskToBack();
                return true;
              },
              child: Builder(builder: (context) {
                Res.isPhone = Device.get().isPhone;
                return GetMaterialApp(
                  key: _nestedKey,
                  initialBinding: ControllersBinding(),
                  navigatorObservers: [RouteObserverProvider.of(context)],
                  theme: ThemeData(
                    useMaterial3: true,
                    primarySwatch: Colors.blue,
                    iconTheme: const IconThemeData(color: Colors.black),
                    textTheme: TextTheme(
                      bodyMedium: const TextStyle(
                          color: Colors.black, fontFamily: 'arial'),
                      displayMedium: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'arial',
                      ),
                      displayLarge: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'arial',
                          fontSize: 16),
                      displaySmall: TextStyle(
                          color: Colors.black,
                          fontFamily: 'arial',
                          fontSize: Res.isPhone ? 13 : 15.0),
                      bodyLarge: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'arial',
                      ),
                      bodySmall: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'arial',
                      ),
                    ),
                  ),
                  debugShowCheckedModeBanner: false,
                  navigatorKey: _navigationKey,
                  home: _screens[0],
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  void _initFirebase() {
    FirebaseMessaging.onMessage.listen((msg) async {
      debugPrint('listen notification     ${msg.data}');
      if (msg.data.get('type') == 'chat') {
        if (Res.chatScreenLevel == ChatScreenLevel.none) {
          await Get.find<HomeController>().countMessages();
          FlutterRingtonePlayer.play(fromAsset: 'assets/sounds/notif.mp3');
        }
        Res.gotMessages.value = true;
      } else {
        await Get.find<HomeController>().getNotifications();
        FlutterRingtonePlayer.play(fromAsset: 'assets/sounds/notif.mp3');
      }
    });

    // FirebaseMessaging.onBackgroundMessage(_onBgNotif);
  }

  /*Future<void> _onBgNotif(RemoteMessage msg) async {
    if (msg.data.get('type') == 'chat') {
      if (Res.chatScreenLevel == ChatScreenLevel.none) {
        FlutterRingtonePlayer.play(fromAsset: 'assets/sounds/notif.mp3');
      }
      Res.gotMessages.value = true;
    }
  }*/

  _buildTitle() {
    if (Res.titleWidget.value != null) {
      return Res.titleWidget.value!;
    }

    return InkWell(
      onTap: () {
        if (_navigationKey.currentState?.canPop() ?? true) {
          Navigator.maybePop(Get.context!);
        } else {
          Get.offAll(() => _screens[0]);
          _pageIndex.value = 0;
        }
        Res.showAppBar.value = true;
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
          color: Colors.black,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (Res.appBarActions.isEmpty) {
      return [
        InkWell(
          onTap: () => Get.to(() => const ChatListScreen()),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Obx(() {
                final unread = Get.find<HomeController>().unreadConversations;
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: unread > 0 ? 8.0 : .0, right: unread > 0 ? 3.0 : .0),
                      child: SvgPicture.asset('assets/ic_chat.svg'),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: .0,
                        right: .0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            unread < 10 ?
                            unread.toString() : '\u{FF0A}',
                            style: TextStyle(
                                fontFamily: 'arial', color: Colors.white, fontSize: unread < 10 ? 11.0 : 8.0),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
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
          ),
        )
      ];
    }

    return Res.appBarActions;
  }
}
