import 'package:flutter/material.dart';

class CustomSpacer extends StatelessWidget {
  final int flex;
  
  const CustomSpacer({super.key, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Spacer(
      flex: flex,
    );
  }
}

