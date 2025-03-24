import 'package:flutter/material.dart';

class CustomInkResponse extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  
  const CustomInkResponse({super.key, required this.child, this.onTap, this.onDoubleTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

