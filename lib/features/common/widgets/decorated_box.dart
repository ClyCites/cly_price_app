import 'package:flutter/material.dart';

class CustomDecoratedBox extends StatelessWidget {
  final Widget child;
  final Decoration decoration;
  final DecorationPosition position;
  
  const CustomDecoratedBox({super.key, required this.child, required this.decoration, this.position = DecorationPosition.background});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration,
      position: position,
      child: child,
    );
  }
}

