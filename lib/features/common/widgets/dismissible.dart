import 'package:flutter/material.dart';

class CustomDismissible extends StatelessWidget {
  final Widget child;
  final Key key;
  final DismissDirection direction;
  final VoidCallback onDismissed;
  
  // const CustomDismissible({super.key, required this.child, required this.direction, required this.onDismissed});
  const CustomDismissible({required this.key, required this.child, required this.direction, required this.onDismissed});
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      direction: direction,
      onDismissed: (direction) {
        onDismissed();
      },
      child: child,
    );
  }
}

