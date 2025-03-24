import 'package:flutter/material.dart';

class CustomAbsorbPointer extends StatelessWidget {
  final Widget child;
  final bool absorbing;
  
  const CustomAbsorbPointer({super.key, required this.child, this.absorbing = true});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: absorbing,
      child: child,
    );
  }
}

