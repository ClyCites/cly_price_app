import 'package:flutter/material.dart';

class CustomClipPath extends StatelessWidget {
  final Widget child;
  final CustomClipper<Path> clipper;
  
  const CustomClipPath({super.key, required this.child, required this.clipper});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: clipper,
      child: child,
    );
  }
}

