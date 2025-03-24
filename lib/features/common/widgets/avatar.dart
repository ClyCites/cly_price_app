import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  
  const Avatar({super.key, this.imageUrl, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null ? const Icon(Icons.person) : null,
    );
  }
}

