import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  const CustomInkWell({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: child,
    );
  }
}

