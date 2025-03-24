import 'package:flutter/material.dart';

class CustomAnimatedBuilder extends StatelessWidget {
  final Animation<dynamic> animation;
  final Widget? child;
  final TransitionBuilder builder;
  
  const CustomAnimatedBuilder({super.key, required this.animation, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

