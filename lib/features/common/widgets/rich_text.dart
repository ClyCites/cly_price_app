import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final TextSpan text;
  
  const CustomRichText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: text,
    );
  }
}

