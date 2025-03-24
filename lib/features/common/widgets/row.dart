import 'package:flutter/material.dart';

class CustomRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  
  const CustomRow({super.key, required this.children, this.mainAxisAlignment = MainAxisAlignment.start, this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

