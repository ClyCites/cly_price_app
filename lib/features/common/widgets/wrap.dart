import 'package:flutter/material.dart';

class CustomWrap extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  
  const CustomWrap({super.key, required this.children, this.direction = Axis.horizontal, this.alignment = WrapAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      children: children,
    );
  }
}

