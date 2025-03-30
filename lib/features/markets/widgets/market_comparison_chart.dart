import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class MarketComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String product;

  const MarketComparisonChart({
    Key? key,
    required this.data,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Responsive text sizes
    final titleSize = size.width * 0.04;
    final subtitleSize = size.width * 0.03;
    final smallTextSize = size.width * 0.028;
    
    // Responsive spacing
    final padding = size.width * 0.04;
    final spacing = size.height * 0.01;
    
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available for $product',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: subtitleSize,
          ),
        ),
      );
    }

    // Sort data by price for better visualization
    final sortedData = List<Map<String, dynamic>>.from(data)
      ..sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));

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
            Text(
              'Price Comparison for $product',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing),
            Text(
              '${data.length} markets available',
              style: TextStyle(
                fontSize: smallTextSize,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: spacing * 1.5),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Adjust bar width based on available width and number of bars
                  final availableWidth = constraints.maxWidth;
                  final barWidth = (availableWidth / (data.length * 2)).clamp(8.0, 20.0);
                  
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY() * 1.1,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          tooltipPadding: EdgeInsets.all(size.width * 0.02),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (groupIndex >= data.length) return null;
                            final market = _getMarketName(data[groupIndex]['market']);
                            final price = data[groupIndex]['price'];
                            return BarTooltipItem(
                              '$market\n',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: smallTextSize * 1.1,
                              ),
                              children: [
                                TextSpan(
                                  text: NumberFormat.currency(
                                    symbol: 'UGX ',
                                    decimalDigits: 0,
                                  ).format(price),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: smallTextSize * 1.2,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= data.length) {
                                return const SizedBox();
                              }
                              
                              final marketName = _getMarketName(data[index]['market']);
                              // Abbreviate market name to fit in the chart
                              final abbreviatedName = _abbreviateMarketName(marketName);
                              
                              // Determine if we should show this label based on available space
                              final shouldShow = data.length <= 5 || index % 2 == 0;
                              
                              if (!shouldShow) {
                                return const SizedBox();
                              }
                              
                              return SideTitleWidget(
                                meta: meta, // Added the required 'meta' parameter
                                space: 8,
                                child: Text(
                                  abbreviatedName,
                                  style: TextStyle(
                                    fontSize: smallTextSize * 0.9,
                                    color: AppColors.textMedium,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                            reservedSize: size.height * 0.03,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                meta: meta, 
                                space: 8,
                                child: Text(
                                  NumberFormat.compact().format(value),
                                  style: TextStyle(
                                    fontSize: smallTextSize * 0.9,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              );
                            },
                            reservedSize: size.width * 0.08,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: _getBarGroups(barWidth),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                        horizontalInterval: _getYAxisInterval(),
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

  List<BarChartGroupData> _getBarGroups(double barWidth) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      // Ensure price is a double
      final price = item['price'] is int 
          ? (item['price'] as int).toDouble() 
          : item['price'] as double;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: price,
            color: AppColors.primary,
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    return data.map((item) => item['price'] as num).reduce((a, b) => a > b ? a : b).toDouble();
  }

  String _getMarketName(dynamic marketData) {
    if (marketData is String) {
      return marketData;
    } else if (marketData is Map) {
      return marketData['name'] as String? ?? 'Unknown Market';
    }
    return 'Unknown Market';
  }

  String _abbreviateMarketName(String name) {
    if (name.length <= 10) return name;
    
    final words = name.split(' ');
    if (words.length <= 1) return name.substring(0, 10);
    
    // Create abbreviation using first letters of words
    final abbreviation = words.map((word) => word.isNotEmpty ? word[0] : '').join('');
    if (abbreviation.length <= 5) return abbreviation;
    
    // If still too long, just return first 10 characters
    return name.substring(0, 10);
  }

  double _getYAxisInterval() {
    final maxY = _getMaxY();
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    return 5000;
  }
}

