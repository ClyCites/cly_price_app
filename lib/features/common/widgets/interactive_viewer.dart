import 'package:flutter/material.dart';

class CustomInteractiveViewer extends StatelessWidget {
  final Widget child;
  
  const CustomInteractiveViewer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: child,
    );
  }
}

