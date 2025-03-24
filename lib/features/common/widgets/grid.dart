import 'package:flutter/material.dart';

class CustomGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;
  
  const CustomGrid({super.key, required this.crossAxisCount, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children: children,
    );
  }
}

