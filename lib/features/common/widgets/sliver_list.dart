import 'package:flutter/material.dart';

class CustomSliverList extends StatelessWidget {
  final SliverChildDelegate delegate;
  
  const CustomSliverList({super.key, required this.delegate});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: delegate,
    );
  }
}

