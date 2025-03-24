import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final List<Step> steps;
  
  const CustomStepper({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Stepper(
      steps: steps,
    );
  }
}

