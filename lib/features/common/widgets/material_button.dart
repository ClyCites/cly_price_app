import 'package:flutter/material.dart';

class CustomMaterialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  
  const CustomMaterialButton({super.key, required this.child, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: color,
      child: child,
    );
  }
}

