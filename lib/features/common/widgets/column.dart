import 'package:flutter/material.dart';

class CustomColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  
  const CustomColumn({super.key, required this.children, this.mainAxisAlignment = MainAxisAlignment.start, this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

