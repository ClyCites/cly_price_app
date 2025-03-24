import 'package:flutter/material.dart';

class CustomIntrinsicWidth extends StatelessWidget {
  final Widget child;
  
  const CustomIntrinsicWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: child,
    );
  }
}

