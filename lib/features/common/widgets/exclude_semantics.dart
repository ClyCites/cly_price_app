import 'package:flutter/material.dart';

class CustomExcludeSemantics extends StatelessWidget {
  final Widget child;
  final bool excluding;
  
  const CustomExcludeSemantics({super.key, required this.child, this.excluding = true});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: excluding,
      child: child,
    );
  }
}

