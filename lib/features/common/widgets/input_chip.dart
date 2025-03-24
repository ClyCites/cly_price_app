import 'package:flutter/material.dart';

class CustomInputChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  
  const CustomInputChip({super.key, required this.label, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
    );
  }
}

