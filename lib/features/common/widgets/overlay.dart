import 'package:flutter/material.dart';

class CustomOverlay extends StatelessWidget {
  final OverlayEntry overlayEntry;
  
  const CustomOverlay({super.key, required this.overlayEntry});

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [overlayEntry],
    );
  }
}

