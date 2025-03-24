import 'package:flutter/material.dart';

class CustomOpacity extends StatelessWidget {
  final Widget child;
  final double opacity;
  
  const CustomOpacity({super.key, required this.child, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: child,
    );
  }
}

