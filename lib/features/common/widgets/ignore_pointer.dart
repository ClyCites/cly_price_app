import 'package:flutter/material.dart';

class CustomIgnorePointer extends StatelessWidget {
  final Widget child;
  final bool ignoring;
  
  const CustomIgnorePointer({super.key, required this.child, this.ignoring = true});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: ignoring,
      child: child,
    );
  }
}

