import 'package:flutter/material.dart';

class CustomInheritedNotifier<T extends Listenable> extends InheritedNotifier<T> {
  const CustomInheritedNotifier({super.key, required super.notifier, required super.child});
}

