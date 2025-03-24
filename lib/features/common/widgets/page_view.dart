import 'package:flutter/material.dart';

class CustomPageView extends StatelessWidget {
  final List<Widget> children;
  
  const CustomPageView({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: children,
    );
  }
}

