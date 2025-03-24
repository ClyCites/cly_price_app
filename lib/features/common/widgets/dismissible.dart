import 'package:flutter/material.dart';

class CustomDismissible extends StatelessWidget {
  final Widget child;
  @override
  final String key;
  final DismissDirection direction;
  final VoidCallback onDismissed;
  
  const CustomDismissible({super.key, required this.child, required this.key, required this.direction, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(key),
      direction: direction,
      onDismissed: (direction) {
        onDismissed();
      },
      child: child,
    );
  }
}

