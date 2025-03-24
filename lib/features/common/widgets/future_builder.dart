import 'package:flutter/material.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;
  
  const CustomFutureBuilder({super.key, required this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: builder,
    );
  }
}

