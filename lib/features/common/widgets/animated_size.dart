import 'package:flutter/material.dart';

class CustomAnimatedSize extends StatelessWidget {
  final Widget child;
  final Duration duration;
  
  const CustomAnimatedSize({super.key, required this.child, required this.duration});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      child: child,
    );
  }
}

