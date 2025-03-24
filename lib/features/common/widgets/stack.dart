import 'package:flutter/material.dart';

class CustomStack extends StatelessWidget {
  final List<Widget> children;
  
  const CustomStack({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children,
    );
  }
}

