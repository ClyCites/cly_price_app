import 'package:flutter/material.dart';

class CustomRotatedBox extends StatelessWidget {
  final Widget child;
  final int quarterTurns;
  
  const CustomRotatedBox({super.key, required this.child, required this.quarterTurns});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: child,
    );
  }
}

