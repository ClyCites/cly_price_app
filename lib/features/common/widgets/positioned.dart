import 'package:flutter/material.dart';

class CustomPositioned extends StatelessWidget {
  final Widget child;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  
  const CustomPositioned({super.key, required this.child, this.left, this.top, this.right, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: child,
    );
  }
}

