import 'package:flutter/material.dart';

class CustomPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  
  const CustomPlaceholder({super.key, this.width, this.height, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      fallbackWidth: width ?? 400.0,
      fallbackHeight: height ?? 400.0,
      color: color,
    );
  }
}

