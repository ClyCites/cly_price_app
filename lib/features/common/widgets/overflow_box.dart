import 'package:flutter/material.dart';

class CustomOverflowBox extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;
  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;
  
  const CustomOverflowBox({super.key, required this.child, this.alignment = Alignment.center, this.maxWidth, this.maxHeight, this.minWidth, this.minHeight});

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: alignment,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      minWidth: minWidth,
      minHeight: minHeight,
      child: child,
    );
  }
}

