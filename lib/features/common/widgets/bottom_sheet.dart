import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final Function(BuildContext) builder;
  
  const CustomBottomSheet({super.key, required this.child, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: builder,
        );
      },
      child: child,
    );
  }
}

