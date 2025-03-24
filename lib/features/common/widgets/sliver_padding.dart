import 'package:flutter/material.dart';

class CustomSliverPadding extends StatelessWidget {
  final Widget sliver;
  final EdgeInsetsGeometry padding;
  
  const CustomSliverPadding({super.key, required this.sliver, required this.padding});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: sliver,
    );
  }
}

