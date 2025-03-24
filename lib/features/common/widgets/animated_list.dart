import 'package:flutter/material.dart';

class CustomAnimatedList extends StatelessWidget {
  final GlobalKey<AnimatedListState> key;
  final IndexedWidgetBuilder itemBuilder;
  final int initialItemCount;
  
  const CustomAnimatedList({super.key, required this.key, required this.itemBuilder, required this.initialItemCount});

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: key,
      initialItemCount: initialItemCount,
      itemBuilder: itemBuilder,
    );
  }
}

