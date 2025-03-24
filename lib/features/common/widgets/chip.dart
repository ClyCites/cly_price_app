import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  
  const CustomChip({super.key, required this.label, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
    );
  }
}

