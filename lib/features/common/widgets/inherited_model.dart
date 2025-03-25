import 'package:flutter/material.dart';

class CustomInheritedModel extends InheritedModel<Object> {
  const CustomInheritedModel({super.key, required super.child});

  @override
  bool updateShouldNotify(InheritedModel oldWidget) {
    return false;
  }

  @override
  bool updateShouldNotifyDependent(InheritedModel<Object> oldWidget, Set<Object> dependencies) {
    return false;
  }
}

