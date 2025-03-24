import 'package:flutter/material.dart';

class CustomSelectableText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  
  const CustomSelectableText({super.key, required this.data, this.style});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      data,
      style: style,
    );
  }
}

