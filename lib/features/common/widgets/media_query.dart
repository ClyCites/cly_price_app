import 'package:flutter/material.dart';

class CustomMediaQuery extends StatelessWidget {
  final Widget child;
  final MediaQueryData data;
  
  const CustomMediaQuery({super.key, required this.child, required this.data});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: data,
      child: child,
    );
  }
}

