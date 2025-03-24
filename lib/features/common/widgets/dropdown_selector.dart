import 'package:flutter/material.dart';

class DropdownSelector<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String Function(T) getLabel;
  final Function(T?) onChanged;
  
  const DropdownSelector({super.key, required this.items, required this.value, required this.getLabel, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(getLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

