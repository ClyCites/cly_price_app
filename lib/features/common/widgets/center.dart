import 'package:flutter/material.dart';

class CustomCenter extends StatelessWidget {
  final Widget? child;
  
  const CustomCenter({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: child,
    );
  }
}

