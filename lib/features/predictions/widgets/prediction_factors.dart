import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PredictionFactors extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final String productName;
  final String marketName;

  const PredictionFactors({
    Key? key,
    required this.prediction,
    required this.productName,
    required this.marketName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final factors = prediction['factors'] as List<dynamic>? ?? [];
    final confidence = prediction['confidence'] as double? ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prediction Factors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(confidence).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getConfidenceIcon(confidence),
                        size: 12,
                        color: _getConfidenceColor(confidence),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(confidence * 100).toStringAsFixed(0)}% Confidence',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getConfidenceColor(confidence),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Factors list
            Expanded(
              child: factors.isEmpty
                  ? _buildDefaultFactors()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: factors.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final factor = factors[index];
                        final name = factor['name'] as String? ?? 'Factor ${index + 1}';
                        final impact = factor['impact'] as double? ?? 0;
                        final description = factor['description'] as String? ?? '';
                        
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getImpactColor(impact).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                _getImpactIcon(impact),
                                color: _getImpactColor(impact),
                                size: 20,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getImpactColor(impact).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatImpact(impact),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getImpactColor(impact),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFactors() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.analytics_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'No specific factors available',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Our prediction is based on historical price trends',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) {
      return Colors.green;
    } else if (confidence >= 0.4) {
      return Colors.orange;
    }
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.7) {
      return Icons.check_circle;
    } else if (confidence >= 0.4) {
      return Icons.info;
    }
    return Icons.warning;
  }

  Color _getImpactColor(double impact) {
    if (impact > 0) {
      return Colors.green;
    } else if (impact < 0) {
      return Colors.red;
    }
    return Colors.orange;
  }

  IconData _getImpactIcon(double impact) {
    if (impact > 0) {
      return Icons.trending_up;
    } else if (impact < 0) {
      return Icons.trending_down;
    }
    return Icons.trending_flat;
  }

  String _formatImpact(double impact) {
    final sign = impact >= 0 ? '+' : '';
    return '$sign${impact.toStringAsFixed(1)}%';
  }
}

