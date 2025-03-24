import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> tabs;
  
  const CustomTabBar({super.key, required this.tabs});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabs: tabs,
    );
  }
}

