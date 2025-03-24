import 'package:flutter/material.dart';

class CustomFlexible extends StatelessWidget {
  final Widget child;
  final int flex;
  final FlexFit fit;
  
  const CustomFlexible({super.key, required this.child, this.flex = 1, this.fit = FlexFit.loose});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      fit: fit,
      child: child,
    );
  }
}

