import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'navigation_bar_item.dart';

// ignore: must_be_immutable
class CustomNavBar extends StatefulWidget {
  final Color indicatorColor;
  final Color activeColor;
  final Color inactiveColor;
  final bool shadow;
  int currentIndex;
  late Widget iconData;
  final ValueChanged<int> onTap;
  final List<CustomNavBarItem> items;

  CustomNavBar({
    Key? key,
    required this.onTap,
    required this.items,
    this.activeColor = Colors.teal,
    this.inactiveColor = Colors.grey,
    this.indicatorColor = Colors.grey,
    this.shadow = true,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  static const double barHeight = 60;
  static const double indicatorHeight = 4;

  List<CustomNavBarItem> get items => widget.items;

  double width = 0;
  late Color activeColor;
  Duration duration = const Duration(milliseconds: 170);

  double? _getIndicatorPosition(int index) {
    var isLtr = Directionality.of(context) == TextDirection.ltr;
    if (isLtr) {
      return lerpDouble(-1.0, 1.0, index / (items.length - 1));
    } else {
      return lerpDouble(1.0, -1.0, index / (items.length - 1));
    }
  }

  @override
  void initState() {
    super.initState();
    widget.iconData = widget.items[0].icon;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    activeColor = widget.activeColor;

    return Container(
      height: barHeight + MediaQuery.of(context).viewPadding.bottom,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: widget.shadow
            ? [
                const BoxShadow(color: Colors.black12, blurRadius: 10),
              ]
            : null,
      ),
      child: Stack(
        //overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            top: indicatorHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((item) {
                var index = items.indexOf(item);
                return GestureDetector(
                  onTap: () => _select(index, item),
                  child: _buildItemWidget(item, index == widget.currentIndex),
                );
              }).toList(),
            ),
          ),
          Positioned(
            top: 0,
            width: width,
            child: AnimatedAlign(
              alignment:
                  Alignment(_getIndicatorPosition(widget.currentIndex)!, 0),
              curve: Curves.linear,
              duration: duration,
              child: Container(
                color: widget.indicatorColor,
                width: width / items.length,
                height: indicatorHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _select(int index, CustomNavBarItem item) {
    widget.currentIndex = index;
    widget.iconData = item.activeIcon ?? item.icon;
    widget.onTap(widget.currentIndex);

    setState(() {});
  }

  Widget _setIcon(CustomNavBarItem item, bool isSelected) {
    return isSelected ? item.activeIcon ?? item.icon : item.icon;
  }

  Widget _buildItemWidget(
      CustomNavBarItem item, bool isSelected) {
    return Container(
      color: item.backgroundColor,
      height: barHeight,
      width: width / items.length,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Tooltip(message: item.tooltip, child: _setIcon(item, isSelected)),
        ],
      ),
    );
  }
}
