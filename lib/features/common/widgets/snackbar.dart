import 'package:flutter/material.dart';

class AppSnackbar {
  static void showSnackbar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

