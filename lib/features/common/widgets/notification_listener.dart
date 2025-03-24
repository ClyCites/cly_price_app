import 'package:flutter/material.dart';

class CustomNotificationListener<T extends Notification> extends StatelessWidget {
  final Widget child;
  final bool Function(T) onNotification;
  
  const CustomNotificationListener({super.key, required this.child, required this.onNotification});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<T>(
      onNotification: onNotification,
      child: child,
    );
  }
}

