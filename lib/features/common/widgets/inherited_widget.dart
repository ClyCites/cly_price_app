import 'package:flutter/material.dart';

class CustomInheritedWidget extends InheritedWidget {
  const CustomInheritedWidget({super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

