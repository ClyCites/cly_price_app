import 'package:flutter/material.dart';

class CustomOffstage extends StatelessWidget {
  final Widget child;
  final bool offstage;
  
  const CustomOffstage({super.key, required this.child, this.offstage = true});

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: offstage,
      child: child,
    );
  }
}

