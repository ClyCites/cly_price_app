import 'package:flutter/material.dart';

class CustomLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;
  
  const CustomLayoutBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: builder,
    );
  }
}

