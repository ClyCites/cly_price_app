import 'package:flutter/material.dart';

class CustomAnimatedContainer extends StatelessWidget {
  final Widget? child;
  final Duration duration;
  final double? width;
  final double? height;
  final Color? color;
  
  const CustomAnimatedContainer({super.key, required this.child, required this.duration, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      width: width,
      height: height,
      color: color,
      child: child,
    );
  }
}

