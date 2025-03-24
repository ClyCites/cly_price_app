import 'package:flutter/material.dart';

class CustomExpansionPanelList extends StatelessWidget {
  final List<ExpansionPanel> children;
  
  const CustomExpansionPanelList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      children: children,
    );
  }
}

