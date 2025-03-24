import 'package:flutter/material.dart';

class CustomBaseline extends StatelessWidget {
  final Widget child;
  final double baseline;
  final TextBaseline baselineType;
  
  const CustomBaseline({super.key, required this.child, required this.baseline, required this.baselineType});

  @override
  Widget build(BuildContext context) {
    return Baseline(
      baseline: baseline,
      baselineType: baselineType,
      child: child,
    );
  }
}

