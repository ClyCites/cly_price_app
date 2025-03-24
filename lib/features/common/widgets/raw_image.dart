import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CustomRawImage extends StatelessWidget {
  final ui.Image image;
  final double? width;
  final double? height;
  
  const CustomRawImage({super.key, required this.image, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: image,
      width: width,
      height: height,
    );
  }
}

