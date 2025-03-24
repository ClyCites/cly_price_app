import 'package:flutter/material.dart';

class CustomRangeSlider extends StatelessWidget {
  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  
  const CustomRangeSlider({super.key, required this.values, required this.onChanged, this.min = 0.0, this.max = 1.0});

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: values,
      onChanged: onChanged,
            min: min,
            max: max,
          );
        }
      }

