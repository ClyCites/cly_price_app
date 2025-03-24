import 'package:flutter/material.dart';

class CustomBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  
  const CustomBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: builder,
    );
  }
}

