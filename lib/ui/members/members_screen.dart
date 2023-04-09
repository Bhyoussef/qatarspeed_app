import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/friends_controller.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/member_widget.dart';
import 'package:qatar_speed/ui/notifications/notifications_screen.dart';
import 'package:qatar_speed/ui/profile/profile_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen>
    with RouteAware, RouteObserverMixin, TickerProviderStateMixin {
  final _searchController = TextEditingController().obs;
  late TabController _tabController;
  final _tabBarKey = GlobalKey();
  final _tabBarWidth = .0.obs;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _tabBarWidth.value =
          ((_tabBarKey.currentContext?.findRenderObject()) as RenderBox)
              .size
              .width;
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 60.0, bottom: 20.0, top: 20.0),
              child: _searchWidget(),
            ),
            _tabs(),
          ],
        ),
      ),
    );
  }

  @override
  void didPush() {
    super.didPush();
    _initAppbar();
  }

  @override
  void didPopNext() {
    _initAppbar();
    super.didPopNext();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.scrollController.value = _scrollController;
      Res.titleWidget.value = null;
      Res.showAppBar.value = true;
      Res.appBarActions.value = [
        InkWell(
          onTap: () =>Get.to(() => const NotificationsScreen()),
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
    });
  }

  Widget _searchWidget() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffB1B1B1).withOpacity(.05),
        borderRadius: BorderRadius.circular(900),
        border: Border.all(color: const Color(0xff2D3F7B).withOpacity(.1)),
      ),
      child: TextField(
        controller: _searchController.value,
        onChanged: Get.find<FriendsController>().searchUser,
        decoration: const InputDecoration(
          hintText: 'search members',
          //isDense: true,
          hintStyle: TextStyle(fontWeight: FontWeight.bold),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black26,
          ),
          border: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _tabs() {
    return Expanded(
      child: GetBuilder<FriendsController>(
        builder: (controller) {
          return Column(
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
                          tabs: const [
                            /*Tab(
                          text: 'Online Users',
                        ),*/
                            Tab(
                              text: 'Followers',
                            ),
                            Tab(
                              text: 'Following',
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          //_list(members: _onlineUsers),
                          _list(controller,
                              members: controller.friends.followers, stilLoading: controller.canLoadMoreFollowers),
                          _list(controller,
                              members: controller.friends.following, stilLoading: controller.canLoadMoreFollowing),
                        ],
                      ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _list(FriendsController controller,
      {required List<UserModel> members, bool stilLoading = true}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            itemCount: members.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return MemberWidget(
                showbutton: false,
                onFollow: () => controller.toggleFollowing(members[index]),
                member: members[index],
                onUserTap: (UserModel? user) {
                  Get.to(() => ProfileScreen(
                        user: members[index],
                      ));
                },
              );
            },
          ),
          if (stilLoading)
            const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
