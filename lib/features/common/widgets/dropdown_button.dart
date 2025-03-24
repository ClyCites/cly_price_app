import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  
  const CustomDropdownButton({super.key, required this.items, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}

