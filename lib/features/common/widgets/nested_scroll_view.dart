import 'package:flutter/material.dart';

class CustomNestedScrollView extends StatelessWidget {
  final Widget headerSliverBuilder;
  final Widget body;
  
  const CustomNestedScrollView({super.key, required this.headerSliverBuilder, required this.body});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: headerSliverBuilder,
          ),
        ];
      },
      body: body,
    );
  }
}

