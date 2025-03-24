import 'package:flutter/material.dart';

class CustomSwitchListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? title;
  final Widget? subtitle;
  
  const CustomSwitchListTile({super.key, required this.value, required this.onChanged, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: title,
      subtitle: subtitle,
    );
  }
}

