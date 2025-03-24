import 'package:flutter/material.dart';

class CustomDropdownButtonFormField<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? Function(T?)? validator;
  
  const CustomDropdownButtonFormField({super.key, required this.items, required this.onChanged, required this.value, this.validator});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}

