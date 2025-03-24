import 'package:flutter/material.dart';

class CustomAnimatedPositioned extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  
  const CustomAnimatedPositioned({super.key, required this.child, required this.duration, this.left, this.top, this.right, this.bottom});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: duration,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: child,
    );
  }
}

