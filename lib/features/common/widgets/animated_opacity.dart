import 'package:flutter/material.dart';

class CustomAnimatedOpacity extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double opacity;
  
  const CustomAnimatedOpacity({super.key, required this.child, required this.duration, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      opacity: opacity,
      child: child,
    );
  }
}

