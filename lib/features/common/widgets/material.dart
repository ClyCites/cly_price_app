import 'package:flutter/material.dart';

class CustomMaterial extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double elevation;
  final ShapeBorder? shape;
  
  const CustomMaterial({super.key, required this.child, this.color, this.elevation = 0.0, this.shape});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: elevation,
      shape: shape,
      child: child,
    );
  }
}

