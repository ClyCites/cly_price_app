import 'package:flutter/material.dart';

class CustomIntrinsicHeight extends StatelessWidget {
  final Widget child;
  
  const CustomIntrinsicHeight({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: child,
    );
  }
}

