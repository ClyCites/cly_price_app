import 'package:flutter/material.dart';

class CustomConstrainedBox extends StatelessWidget {
  final Widget child;
  final BoxConstraints constraints;
  
  const CustomConstrainedBox({super.key, required this.child, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: child,
    );
  }
}

