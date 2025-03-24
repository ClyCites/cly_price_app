import 'package:flutter/material.dart';

class CustomInheritedModel extends InheritedModel {
  const CustomInheritedModel({super.key, required super.child});

  @override
  bool updateShouldNotify(InheritedModel oldWidget) {
    return false;
  }

  @override
  bool updateShouldNotifyDependentScope(InheritedModel oldWidget, Set<Object> dependencies) {
    return false;
  }
}

