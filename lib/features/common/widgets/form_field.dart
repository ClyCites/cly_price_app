import 'package:flutter/material.dart';

class CustomFormField<T> extends StatelessWidget {
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final T? initialValue;
  final Widget Function(FormFieldState<T>) builder;
  
  const CustomFormField({super.key, this.validator, this.onSaved, this.initialValue, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: validator,
      onSaved: onSaved,
      initialValue: initialValue,
      builder: builder,
    );
  }
}

