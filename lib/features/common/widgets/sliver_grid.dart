import 'package:flutter/material.dart';

class CustomSliverGrid extends StatelessWidget {
  final SliverChildDelegate delegate;
  final SliverGridDelegate gridDelegate;
  
  const CustomSliverGrid({super.key, required this.delegate, required this.gridDelegate});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: delegate,
      gridDelegate: gridDelegate,
    );
  }
}

