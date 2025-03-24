import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<TableRow> children;
  
  const CustomTable({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Table(
      children: children,
    );
  }
}

