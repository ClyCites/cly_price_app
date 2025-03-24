import 'package:flutter/material.dart';

class CustomTransform extends StatelessWidget {
  final Widget child;
  final Matrix4 transform;
  
  const CustomTransform({super.key, required this.child, required this.transform});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: transform,
      child: child,
    );
  }
}

