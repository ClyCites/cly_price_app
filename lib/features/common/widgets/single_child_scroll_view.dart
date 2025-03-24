import 'package:flutter/material.dart';

class CustomSingleChildScrollView extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  
  const CustomSingleChildScrollView({super.key, required this.child, this.scrollDirection = Axis.vertical, this.reverse = false, this.padding});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      padding: padding,
      child: child,
    );
  }
}

