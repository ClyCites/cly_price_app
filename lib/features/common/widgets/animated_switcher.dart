import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  
  const CustomAnimatedSwitcher({super.key, required this.child, required this.duration});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: child,
    );
  }
}

