import 'package:flutter/material.dart';

class CustomPhysicalShape extends StatelessWidget {
  final Widget child;
  final ShapeBorder clipper;
  final Clip clipBehavior;
  final Color color;
  final Color shadowColor;
  final double elevation;
  
  const CustomPhysicalShape({super.key, required this.child, required this.clipper, required this.clipBehavior, required this.color, required this.shadowColor, required this.elevation});

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: ShapeBorderClipper(shape: clipper),
      clipBehavior: clipBehavior,
      color: color,
      shadowColor: shadowColor,
      elevation: elevation,
      child: child,
    );
  }
}

