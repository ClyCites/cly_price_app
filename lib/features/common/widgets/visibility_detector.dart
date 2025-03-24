import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CustomVisibilityDetector extends StatelessWidget {
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;
  @override
  final Key key;
  
  const CustomVisibilityDetector({super.key, required this.key, required this.child, required this.onVisibilityChanged});

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: key,
      onVisibilityChanged: onVisibilityChanged,
      child: child,
    );
  }
}

