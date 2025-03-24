import 'package:flutter/material.dart';

class CustomAlign extends StatelessWidget {
  final Widget? child;
  final AlignmentGeometry alignment;
  
  const CustomAlign({super.key, this.child, this.alignment = Alignment.center});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: child,
    );
  }
}

