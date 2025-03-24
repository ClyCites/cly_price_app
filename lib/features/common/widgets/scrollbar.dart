import 'package:flutter/material.dart';

class CustomScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  
  const CustomScrollbar({super.key, required this.child, this.controller});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: child,
    );
  }
}

