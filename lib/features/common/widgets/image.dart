import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  
  const CustomImage({super.key, required this.imageUrl, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
    );
  }
}

