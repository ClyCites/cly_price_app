import 'package:flutter/material.dart';

class CustomKeepAlive extends StatefulWidget {
  final Widget child;
  final bool keepAlive;
  
  const CustomKeepAlive({super.key, required this.child, this.keepAlive = true});

  @override
  State<CustomKeepAlive> createState() => _CustomKeepAliveState();
}

class _CustomKeepAliveState extends State<CustomKeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

