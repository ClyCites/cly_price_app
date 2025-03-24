import 'package:flutter/material.dart';

class CustomSemantics extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? value;
  final String? hint;
  
  const CustomSemantics({super.key, required this.child, this.label, this.value, this.hint});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: value,
      hint: hint,
      child: child,
    );
  }
}

