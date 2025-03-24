import 'package:flutter/material.dart';

class CustomAspectRatio extends StatelessWidget {
  final Widget child;
  final double aspectRatio;
  
  const CustomAspectRatio({super.key, required this.child, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: child,
    );
  }
}

