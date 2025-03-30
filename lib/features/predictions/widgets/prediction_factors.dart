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
    final size = MediaQuery.of(context).size;
    final factors = prediction['factors'] as List<dynamic>? ?? [];
    final confidence = prediction['confidence'] as double? ?? 0;
    
    // Responsive text sizes
    final titleSize = size.width * 0.04;
    final subtitleSize = size.width * 0.03;
    final smallTextSize = size.width * 0.028;
    
    // Responsive spacing
    final padding = size.width * 0.04;
    final spacing = size.height * 0.015;
    final iconSize = size.width * 0.05;
    final smallIconSize = size.width * 0.03;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prediction Factors',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.height * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(confidence).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getConfidenceIcon(confidence),
                        size: smallIconSize,
                        color: _getConfidenceColor(confidence),
                      ),
                      SizedBox(width: size.width * 0.01),
                      Text(
                        '${(confidence * 100).toStringAsFixed(0)}% Confidence',
                        style: TextStyle(
                          fontSize: smallTextSize,
                          color: _getConfidenceColor(confidence),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spacing),
            
            // Factors list
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (factors.isEmpty) {
                    return _buildDefaultFactors(context);
                  }
                  
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: factors.length,
                    separatorBuilder: (context, index) => Divider(height: size.height * 0.01),
                    itemBuilder: (context, index) {
                      final factor = factors[index];
                      final name = factor['name'] as String? ?? 'Factor ${index + 1}';
                      final impact = factor['impact'] as double? ?? 0;
                      final description = factor['description'] as String? ?? '';
                      
                      // Calculate adaptive height based on available space
                      final itemHeight = constraints.maxHeight / 4.5; // Show about 4-5 items
                      
                      return Container(
                        height: itemHeight,
                        constraints: BoxConstraints(
                          minHeight: size.height * 0.06, // Minimum height
                          maxHeight: size.height * 0.08, // Maximum height
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: iconSize * 2,
                              height: iconSize * 2,
                              decoration: BoxDecoration(
                                color: _getImpactColor(impact).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  _getImpactIcon(impact),
                                  color: _getImpactColor(impact),
                                  size: iconSize,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min, // Use min to avoid overflow
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: subtitleSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: size.height * 0.004),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: smallTextSize,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.height * 0.004,
                              ),
                              decoration: BoxDecoration(
                                color: _getImpactColor(impact).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatImpact(impact),
                                style: TextStyle(
                                  fontSize: smallTextSize,
                                  color: _getImpactColor(impact),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFactors(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final iconSize = size.width * 0.1; // Slightly smaller icon
  final titleSize = size.width * 0.035;
  final subtitleSize = size.width * 0.03;
  
  return LayoutBuilder(
    builder: (context, constraints) {
      // Adjust spacing based on available height
      final availableHeight = constraints.maxHeight;
      final spacing = availableHeight * 0.05; // 5% of available height
      
      return SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Use min to avoid overflow
            children: [
              Icon(
                Icons.analytics_outlined,
                size: iconSize,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: spacing),
              Text(
                'No specific factors available',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing * 0.5),
              Text(
                'Our prediction is based on historical price trends',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    },
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

