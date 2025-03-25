import 'package:flutter/material.dart';

class CustomPhysicalModel extends StatelessWidget {
  final Widget child;
  final BoxShape shape;
  final Clip clipBehavior;
  final Color color;
  final Color shadowColor;
  final double elevation;
  
  const CustomPhysicalModel({super.key, required this.child, required this.shape, required this.clipBehavior, required this.color, required this.shadowColor, required this.elevation});

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      shape: shape,
      clipBehavior: clipBehavior,
      color: color,
      shadowColor: shadowColor,
      elevation: elevation,
      child: child,
    );
  }
}

