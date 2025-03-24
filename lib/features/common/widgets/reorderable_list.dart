import 'package:flutter/material.dart';

class CustomReorderableList extends StatelessWidget {
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final ReorderCallback onReorder;
  
  const CustomReorderableList({super.key, required this.itemBuilder, required this.itemCount, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      onReorder: onReorder,
    );
  }
}

