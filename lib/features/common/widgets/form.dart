import 'package:flutter/material.dart';

class CustomForm extends StatelessWidget {
  final Widget child;
  final GlobalKey<FormState> formKey;
  
  const CustomForm({super.key, required this.child, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: child,
    );
  }
}

