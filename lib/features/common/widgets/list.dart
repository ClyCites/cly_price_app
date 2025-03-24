import 'package:flutter/material.dart';

class CustomList extends StatelessWidget {
  final List<Widget> children;
  
  const CustomList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: children,
    );
  }
}

