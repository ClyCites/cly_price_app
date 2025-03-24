import 'package:flutter/material.dart';

class CustomMergeSemantics extends StatelessWidget {
  final Widget child;
  
  const CustomMergeSemantics({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: child,
    );
  }
}

