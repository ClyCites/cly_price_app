import 'package:flutter/material.dart';

class CustomFlow extends StatelessWidget {
  final FlowDelegate delegate;
  final List<Widget> children;
  
  const CustomFlow({super.key, required this.delegate, required this.children});

  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: delegate,
      children: children,
    );
  }
}

