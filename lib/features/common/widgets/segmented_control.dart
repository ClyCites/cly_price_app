import 'package:flutter/material.dart';

class SegmentedControl<T> extends StatelessWidget {
  final Map<T, Widget> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;
  
  const SegmentedControl({super.key, required this.children, required this.groupValue, required this.onValueChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: children.entries.map((e) => ButtonSegment<T>(value: e.key, label: e.value)).toSet(),
      selected: {groupValue},
      onSelectionChanged: (Set<T> newSelection) {
        onValueChanged(newSelection.first);
      },
    );
  }
}

