import 'package:flutter/material.dart';

class CustomClipOval extends StatelessWidget {
  final Widget child;
  
  const CustomClipOval({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: child,
    );
  }
}

