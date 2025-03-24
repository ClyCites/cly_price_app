import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Widget child;
  
  const CustomDrawer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: child,
    );
  }
}

