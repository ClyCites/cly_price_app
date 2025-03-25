import 'package:flutter/material.dart';

class CustomDraggable<T extends Object> extends StatelessWidget {
  final Widget child;
  final T data;
  final Widget? feedback;
  
  const CustomDraggable({super.key, required this.child, required this.data, this.feedback});

  @override
  Widget build(BuildContext context) {
    return Draggable<T>(
      data: data,
      feedback: feedback ?? child,
      child: child,
    );
  }
}

