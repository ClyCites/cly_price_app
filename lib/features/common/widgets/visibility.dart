import 'package:flutter/material.dart';

class CustomVisibility extends StatelessWidget {
  final Widget child;
  final bool visible;
  
  const CustomVisibility({super.key, required this.child, this.visible = true});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: child,
    );
  }
}

