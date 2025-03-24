import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onSelected;
  
  const FilterChipWidget({super.key, required this.text, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (bool selected) {
        onSelected();
      },
    );
  }
}

