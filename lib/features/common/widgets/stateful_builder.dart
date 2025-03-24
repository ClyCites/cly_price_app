import 'package:flutter/material.dart';

class CustomStatefulBuilder extends StatelessWidget {
  final Widget Function(BuildContext, StateSetter) builder;
  
  const CustomStatefulBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: builder,
    );
  }
}

