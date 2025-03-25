import 'package:flutter/material.dart';

class CustomAnimatedList extends StatelessWidget {
  @override
  final GlobalKey<AnimatedListState> listKey;
  final AnimatedItemBuilder itemBuilder;
  final int initialItemCount;
  
  const CustomAnimatedList({super.key, required this.listKey, required this.itemBuilder, required this.initialItemCount});

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: listKey,
      initialItemCount: initialItemCount,
      itemBuilder: itemBuilder,
    );
  }
}

