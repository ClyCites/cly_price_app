import 'package:flutter/material.dart';

class CustomIndexedStack extends StatelessWidget {
  final List<Widget> children;
  final int index;
  
  const CustomIndexedStack({super.key, required this.children, required this.index});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: children,
    );
  }
}

