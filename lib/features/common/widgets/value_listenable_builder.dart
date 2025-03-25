import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomValueListenableBuilder<T> extends StatelessWidget {
  final ValueListenable<T> valueListenable;
  final Widget Function(BuildContext, T, Widget?) builder;
  final Widget? child;
  
  const CustomValueListenableBuilder({super.key, required this.valueListenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: valueListenable,
      builder: builder,
      child: child,
    );
  }
}

