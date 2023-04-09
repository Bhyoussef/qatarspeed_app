import 'package:flutter/material.dart';

class CustomNavBarItem {
  final Widget icon;
  final Widget? activeIcon;
  final Color backgroundColor;
  final String? tooltip;

  CustomNavBarItem({
    required this.icon,
    this.backgroundColor = Colors.white,
    this.activeIcon,
    this.tooltip,
  });
}
