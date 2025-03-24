import 'package:flutter/material.dart';

class CustomSliverPersistentHeader extends StatelessWidget {
  final SliverPersistentHeaderDelegate delegate;
  final bool pinned;
  final bool floating;
  
  const CustomSliverPersistentHeader({super.key, required this.delegate, this.pinned = false, this.floating = false});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: delegate,
      pinned: pinned,
      floating: floating,
    );
  }
}

