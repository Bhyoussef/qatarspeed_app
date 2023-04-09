import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({Key? key, this.width = 300.0, this.height = 300.0}) : super(key: key);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(highlightColor: Colors.white,
    baseColor: Colors.grey[300]!,
    child: Container(
      color: Colors.grey[300],
      width: width,
      height: height,
    ));
  }
}
