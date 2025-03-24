import 'package:flutter/material.dart';

class CustomScrollView extends StatelessWidget {
  final List<Widget> slivers;
  
  const CustomScrollView({super.key, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: slivers,
    );
  }
}

