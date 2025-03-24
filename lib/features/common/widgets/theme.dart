import 'package:flutter/material.dart';

class CustomTheme extends StatelessWidget {
  final Widget child;
  final ThemeData data;
  
  const CustomTheme({super.key, required this.child, required this.data});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: data,
      child: child,
    );
  }
}

