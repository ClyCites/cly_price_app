import 'package:flutter/material.dart';

class CustomPopupMenuButton<T> extends StatelessWidget {
  final List<PopupMenuEntry<T>> itemBuilder;
  final Function(T)? onSelected;
  
  const CustomPopupMenuButton({super.key, required this.itemBuilder, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      itemBuilder: (BuildContext context) {
        return itemBuilder;
      },
      onSelected: onSelected,
    );
  }
}

