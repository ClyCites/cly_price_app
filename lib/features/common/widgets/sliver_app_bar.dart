import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final Widget? title;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final bool pinned;
  final bool snap;
  final bool floating;
  
  const CustomSliverAppBar({super.key, this.title, this.flexibleSpace, this.actions, this.pinned = false, this.snap = false, this.floating = false});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title,
      flexibleSpace: flexibleSpace,
      actions: actions,
      pinned: pinned,
      snap: snap,
      floating: floating,
    );
  }
}

