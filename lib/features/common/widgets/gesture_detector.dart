import 'package:flutter/material.dart';

class CustomGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  
  const CustomGestureDetector({super.key, required this.child, this.onTap, this.onDoubleTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
    );
  }
}

