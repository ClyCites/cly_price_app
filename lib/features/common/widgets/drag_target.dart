import 'package:flutter/material.dart';

class CustomDragTarget<T> extends StatelessWidget {
  final Widget builder;
  final Function(T) onAccept;
  
  const CustomDragTarget({super.key, required this.builder, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
        return builder;
      },
      onAccept: onAccept,
    );
  }
}

