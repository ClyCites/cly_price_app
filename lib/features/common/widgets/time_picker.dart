import 'package:flutter/material.dart';

class CustomTimePicker extends StatelessWidget {
  final TimeOfDay? initialTime;
  final Function(TimeOfDay?) onTimeSelected;
  
  const CustomTimePicker({super.key, this.initialTime, required this.onTimeSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: const Text('Select Time'),
    );
  }
}

