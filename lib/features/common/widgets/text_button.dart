import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  
  const CustomTextButton({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

