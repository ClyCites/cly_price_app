import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  
  const CustomContainer({super.key, this.child, this.color, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: color,
      child: child,
    );
  }
}

