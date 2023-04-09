import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RefreshLoadmore extends StatefulWidget {
  /// Callback function on pull down to refresh | 下拉刷新时的回调函数
  final Future<void> Function()? onRefresh;

  /// Callback function on pull up to load more data | 上拉以加载更多数据的回调函数
  final Future<void> Function()? onLoadmore;

  /// Whether it is the last page, if it is true, you can not load more | 是否为最后一页，如果为true，则无法加载更多
  final bool isLastPage;

  /// Child widget | 子组件
  final Widget child;

  /// Prompt text widget when there is no more data at the bottom | 底部没有更多数据时的提示文字组件
  final Widget? noMoreWidget;

  /// You can use your custom scrollController, or not | 你可以使用自定义的 ScrollController，或者不使用
  final ScrollController? scrollController;

  final ScrollPhysics physics;

  const RefreshLoadmore({
    Key? key,
    required this.child,
    required this.isLastPage,
    this.onRefresh,
    this.onLoadmore,
    this.noMoreWidget,
    this.scrollController,
    this.physics = const NeverScrollableScrollPhysics(),
  }) : super(key: key);
  @override
  createState() => _RefreshLoadmoreState();
}

class _RefreshLoadmoreState extends State<RefreshLoadmore> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  ScrollController? _scrollController;
  final _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController!.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController!.removeListener(_scrollListener);
    if (widget.scrollController == null) _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWiget = ListView(
      physics: widget.physics,
      shrinkWrap: true,
      children: <Widget>[
        widget.child,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                return _isLoading.value
                    ? const CupertinoActivityIndicator()
                    : widget.isLastPage
                    ? widget.noMoreWidget ??
                    Text(
                      'No more data',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).disabledColor,
                      ),
                    )
                    : Container();
              }),
            ),
          ],
        )
      ],
    );

    if (widget.onRefresh == null) {
      return Scrollbar(child: mainWiget);
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        if (_isLoading.value) return;
        await widget.onRefresh!();
      },
      child: mainWiget,
    );
  }

  _scrollListener() async {
    if (_scrollController!.position.pixels >
        _scrollController!.position.maxScrollExtent - 80.0) {

      if (_isLoading.value) {
        return;
      }

      if (mounted) {
          _isLoading.value = true;
      }

      if (!widget.isLastPage && widget.onLoadmore != null) {
        await widget.onLoadmore!();
      }

      if (mounted) {
          _isLoading.value = false;
      }
    }
  }
}
