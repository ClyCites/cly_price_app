import 'package:flutter/material.dart';

class CustomFittedBox extends StatelessWidget {
  final Widget child;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  
  const CustomFittedBox({super.key, required this.child, this.fit = BoxFit.contain, this.alignment = Alignment.center});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: fit,
      alignment: alignment,
      child: child,
    );
  }
}

