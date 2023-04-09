import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/posts/post_screen.dart';
import 'package:qatar_speed/ui/profile/profile_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../common/shimmer_bocx.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsScreen>
    with RouteAware, RouteObserverMixin, TickerProviderStateMixin {
  final _notifsRefreshController = RefreshController();
  final _tabBarKey = GlobalKey();
  final _tabBarWidth = .0.obs;
  late TabController _tabController;

  @override
  void didPopNext() {
    super.didPopNext();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [const SizedBox.shrink()];
    });
  }

  @override
  void didPush() {
    super.didPush();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [const SizedBox.shrink()];
    });
  }

  @override
  void dispose() {
    super.dispose();
    _notifsRefreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<HomeController>(
      id: 'notifications',
      builder: (controller) {
        if (controller.isLoadingNotifications) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.black),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          try {
            _tabBarWidth.value =
                ((_tabBarKey.currentContext?.findRenderObject()) as RenderBox)
                    .size
                    .width;
          } catch (_) {}
        });
        _tabController =
            TabController(length: controller.notifications.length, vsync: this);

        return SmartRefresher(
          controller: _notifsRefreshController,
          onRefresh: () => controller
              .getNotifications()
              .whenComplete(() => _notifsRefreshController.refreshCompleted()),
          child: controller.notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'arial',
                        fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Stack(
                          fit: StackFit.passthrough,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Obx(() {
                              return Container(
                                width: _tabBarWidth.value,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Color(0xffE2E2E2), width: 3.0),
                                  ),
                                ),
                              );
                            }),
                            TabBar(
                                key: _tabBarKey,
                                controller: _tabController,
                                indicatorColor: const Color(0xffEED600),
                                labelColor: Colors.black,
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: .0),
                                isScrollable: false,
                                indicatorWeight: 3.0,
                                tabs: _buildTabs(controller)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _buildViews(controller),
                      ),
                    ),
                  ],
                ),
        );
      },
    ));
  }

  List<Tab> _buildTabs(HomeController controller) {
    List<Tab> tabs = [];
    controller.notifications.forEach((key, value) {
      tabs.add(Tab(
        text: key,
      ));
    });
    return tabs;
  }

  List<Widget> _buildViews(HomeController controller) {
    List<Widget> views = [];
    controller.notifications.forEach((key, value) {
      views.add(ListView.separated(
        itemCount: value.length,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12.0),
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 1,
          color: Colors.black,
        ),
        itemBuilder: (context, index) {
          final notif = value[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              /*vertical: 5,*/
            ),
            child: ListTile(
              tileColor: notif.isRead ? Colors.transparent : Colors.grey.withOpacity(.3),
              contentPadding: EdgeInsets.symmetric(vertical: 12.0),
              leading: Container(
                foregroundDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.transparent, width: 1.0)),
                child: ClipOval(
                    child: CachedNetworkImage(
                  imageUrl: notif.user.photo ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, _) => ShimmerBox(
                    width: Res.isPhone ? 50.0 : 50.0,
                    height: Res.isPhone ? 50.0 : 50.0,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.blue,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  width: Res.isPhone ? 50.0 : 50.0,
                  height: Res.isPhone ? 50.0 : 50.0,
                )),
              ),
              title: Text('${notif.user.name} ${notif.text}'),
              dense: true,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  timeago.format(notif.createdAt),
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Get.find<HomeController>().readNotification(notif);
                if (notif.type == 'Post' && notif.postId != null) {
                  Get.to(() => PostScreen(post: PostModel(id: notif.postId)));
                } else if (notif.type == 'Follow') {
                  Get.to(() => ProfileScreen(
                        user: notif.user,
                      ));
                }
              },
            ),
          );
        },
      ));
    });
    return views;
  }
}
