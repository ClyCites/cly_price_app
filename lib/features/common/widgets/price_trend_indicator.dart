import 'package:flutter/material.dart';

class PriceTrendIndicator extends StatelessWidget {
  final double change;
  
  const PriceTrendIndicator({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    final isPositive = change > 0;
    
    return Row(
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          color: isPositive ? Colors.green : Colors.red,
          size: 16,
        ),
        Text(
          '${change.toStringAsFixed(2)}%',
          style: TextStyle(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

