import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/search_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/group_widget.dart';
import 'package:qatar_speed/ui/common/member_widget.dart';
import 'package:qatar_speed/ui/common/post_widget.dart';
import 'package:qatar_speed/ui/groups/groups_screen.dart';
import 'package:qatar_speed/ui/profile/profile_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({Key? key, required this.keyword}) : super(key: key);
  final String keyword;

  @override
  createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAppbar();
    Get.find<SearchController>().search(widget.keyword);
  }

  @override
  void dispose() {
    super.dispose();
    _initAppbar();
    Get.find<SearchController>().removeSearch();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScrollAppBar(
        controller: _scrollController,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: _searchWidget(),
      ),
      body: GetBuilder<SearchController>(
        builder: (controller) {
          if (controller.result == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            );
          }
          return _SearchContent(
            scrollController: _scrollController,
            controller: controller,
          );
        },
      ),
    );
  }

  _initAppbar({bool shown = false}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.showAppBar.value = shown;
    });
  }

  Widget _searchWidget() {
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.3),
                borderRadius: BorderRadius.circular(5.0)),
            child: TextFormField(
              maxLines: 1,
              initialValue: widget.keyword,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: Res.isPhone ? 13.0 : 17.0),
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (txt) {
                if (txt.removeAllWhitespace.isNotEmpty) {
                  FocusScope.of(context).unfocus();
                }
              },
              enabled: false,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search here',
                hintStyle: TextStyle(fontSize: Res.isPhone ? 13.0 : 17.0),
                suffixIcon: InkWell(
                    onTap: () {}, child: const Icon(Icons.search)),
                border: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  final SearchController controller;
  final ScrollController scrollController;

  const _SearchContent({
    required this.controller, required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: (controller.result?.length ?? 0) + 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            labelColor: Colors.black,
              isScrollable: true, tabs: [
            const Tab(
              child: Text('All'),
            ),
            if (controller.result?.users.isNotEmpty ?? false)
              const Tab(
                child: Text('Persons'),
              ),
            if (controller.result?.posts.isNotEmpty ?? false)
              const Tab(
                child: Text('Posts'),
              ),
            if (controller.result?.groups.isNotEmpty ?? false)
              const Tab(
                child: Text('Groups'),
              ),
          ]),
          Expanded(
            child: TabBarView(
                children: [
                  _allResults(),
                  if (controller.result!.users.isNotEmpty)
                    ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                      controller: scrollController,
                      children: _usersWidgets(),
                    ),
                  if (controller.result!.posts.isNotEmpty)
                    ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                      controller: scrollController,
                      children: _postsWidgets(),
                    ),
                  if (controller.result!.groups.isNotEmpty)
                    ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                      controller: scrollController,
                      children: _groupsWidgets(),
                    )
                ]
            ),
          )
        ],
      ),
    );
  }

  Widget _allResults() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      controller: scrollController,
      children: [
        if (controller.result!.users.isNotEmpty) ...[
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              'Persons',
              style: TextStyle(
                  fontFamily: 'arial',
                  fontWeight: FontWeight.w900,
                  fontSize: 25.0),
            ),
          ),
          ..._usersWidgets()
        ],
        if (controller.result!.posts.isNotEmpty) ...[
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              'Posts',
              style: TextStyle(
                  fontFamily: 'arial',
                  fontWeight: FontWeight.w900,
                  fontSize: 25.0),
            ),
          ),
          ..._postsWidgets()
        ],
        if (controller.result!.groups.isNotEmpty) ...[
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              'Groups',
              style: TextStyle(
                  fontFamily: 'arial',
                  fontWeight: FontWeight.w900,
                  fontSize: 25.0),
            ),
          ),
          ..._groupsWidgets(),
        ]
      ],
    );
  }


  List<Widget> _usersWidgets() {
    return controller.result!.users
        .map((user) => MemberWidget(
      showbutton: false,
        member: user,
        showPopup: false,
        onUserTap: (usr) => Get.to(ProfileScreen(
          user: usr,
        ))))
        .toList();
  }

  List<Widget> _postsWidgets() {
    return controller.result!.posts
        .map((post) => PostWidget(
      post: post,
    ))
        .toList();
  }

  List<Widget> _groupsWidgets() {
    return controller.result!.groups
        .map((group) => GroupWidget(
      group: group,
      onTap: (grp) {
        Get.to(() => GroupsScreen(
          group: grp,
        ));
      },
      showPopup: false,
    ))
        .toList();
  }
}
