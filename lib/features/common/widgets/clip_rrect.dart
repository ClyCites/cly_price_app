import 'package:flutter/material.dart';

class CustomClipRRect extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  
  const CustomClipRRect({super.key, required this.child, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}

