import 'package:flutter/material.dart';

class CustomInk extends StatelessWidget {
  final Widget child;
  final Color? color;
  final DecorationImage? image;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  
  const CustomInk({super.key, required this.child, this.color, this.image, this.border, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: color,
        image: image,
        border: border,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

