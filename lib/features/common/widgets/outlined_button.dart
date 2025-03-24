import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  
  const CustomOutlinedButton({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

