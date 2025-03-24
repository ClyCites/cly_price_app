import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PredictionFactors extends StatelessWidget {
  final List<Map<String, dynamic>> factors;

  const PredictionFactors({
    super.key,
    required this.factors,
  });

  @override
  Widget build(BuildContext context) {
    if (factors.isEmpty) {
      return Center(
        child: Text(
          'No prediction factors available',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: factors.length,
      itemBuilder: (context, index) {
        final factor = factors[index];
        final name = factor['name'] as String;
        final impact = factor['impact'] as double;
        final description = factor['description'] as String;
        
        // Determine impact color and icon
        final Color impactColor;
        final IconData impactIcon;
        
        if (impact > 0.5) {
          impactColor = AppColors.success;
          impactIcon = Icons.arrow_upward;
        } else if (impact < -0.5) {
          impactColor = AppColors.error;
          impactIcon = Icons.arrow_downward;
        } else {
          impactColor = AppColors.warning;
          impactIcon = Icons.remove;
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: impactColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    impactIcon,
                    color: impactColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 14,
                        ),
                      ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }

