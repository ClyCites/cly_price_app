import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatefulWidget {
  final Function(DateTimeRange?) onDateRangeSelected;
  
  const DateRangePicker({super.key, required this.onDateRangeSelected});

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTimeRange? selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2025),
        );
        if (picked != null && picked != selectedDateRange) {
          setState(() {
            selectedDateRange = picked;
          });
          widget.onDateRangeSelected(picked);
        }
      },
      child: Text(
        selectedDateRange == null
            ? 'Select Date Range'
            : '${DateFormat('MMM d').format(selectedDateRange!.start)} - ${DateFormat('MMM d').format(selectedDateRange!.end)}',
      ),
    );
  }
}

