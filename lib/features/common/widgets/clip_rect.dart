import 'package:flutter/material.dart';

class CustomClipRect extends StatelessWidget {
  final Widget child;
  final CustomClipper<Rect>? clipper;
  
  const CustomClipRect({super.key, required this.child, this.clipper});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: clipper,
      child: child,
    );
  }
}

