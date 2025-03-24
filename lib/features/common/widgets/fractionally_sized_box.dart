import 'package:flutter/material.dart';

class CustomFractionallySizedBox extends StatelessWidget {
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry alignment;
  
  const CustomFractionallySizedBox({super.key, required this.child, this.widthFactor, this.heightFactor, this.alignment = Alignment.center});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      alignment: alignment,
      child: child,
    );
  }
}

