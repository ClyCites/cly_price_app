import 'package:flutter/material.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime?) onDateSelected;
  
  const CustomDatePicker({super.key, this.initialDate, this.firstDate, this.lastDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: const Text('Select Date'),
    );
  }
}

