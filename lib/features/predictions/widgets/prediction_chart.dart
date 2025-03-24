import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class PredictionChart extends StatelessWidget {
  final List<Map<String, dynamic>> predictionData;
  final String product;
  final String timeframe;

  const PredictionChart({
    super.key,
    required this.predictionData,
    required this.product,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    if (predictionData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No prediction data available',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Split data into historical and predicted
    final historicalData = <FlSpot>[];
    final predictedData = <FlSpot>[];
    
    for (int i = 0; i < predictionData.length; i++) {
      final point = predictionData[i];
      final price = point['price'].toDouble();
      final isPredicted = point['isPredicted'] as bool;
      
      if (isPredicted) {
        predictedData.add(FlSpot(i.toDouble(), price));
      } else {
        historicalData.add(FlSpot(i.toDouble(), price));
      }
    }
    
    // Calculate min and max Y values
    final allPrices = predictionData.map((e) => e['price'].toDouble()).toList();
    final minPrice = allPrices.reduce((a, b) => a < b ? a : b);
    final maxPrice = allPrices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getPriceInterval(minPrice, maxPrice),
          verticalInterval: _getInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getInterval(),
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= predictionData.length || value.toInt() < 0) {
                  return const SizedBox();
                }
                final date = DateTime.parse(predictionData[value.toInt()]['date'] as String);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMedium,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getPriceInterval(minPrice, maxPrice),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    NumberFormat.compact().format(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMedium,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade200),
        ),
        minX: 0,
        maxX: predictionData.length - 1.0,
        minY: minPrice - (priceRange * 0.1),
        maxY: maxPrice + (priceRange * 0.1),
        lineBarsData: [
          // Historical data line
          LineChartBarData(
            spots: historicalData,
            isCurved: true,
            color: AppColors.accent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: historicalData.length < 15,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.accent,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withOpacity(0.2),
            ),
          ),
          // Predicted data line
          LineChartBarData(
            spots: predictedData,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: predictedData.length < 15,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.2),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.4),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dashArray: [5, 5], // Make the prediction line dashed
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                final data = predictionData[index];
                final date = DateTime.parse(data['date'] as String);
                final price = data['price'].toDouble();
                final isPredicted = data['isPredicted'] as bool;
                
                return LineTooltipItem(
                  '${_formatDate(date)}\n',
                  const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: NumberFormat.currency(
                        symbol: 'UGX ',
                        decimalDigits: 0,
                      ).format(price),
                      style: TextStyle(
                        color: isPredicted ? AppColors.primary : AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: isPredicted ? ' (Predicted)' : ' (Historical)',
                      style: TextStyle(
                        color: isPredicted ? AppColors.primary : AppColors.accent,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: historicalData.isNotEmpty ? historicalData.last.y : 0,
              color: Colors.grey.shade400,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 10,
                ),
                labelResolver: (line) => 'Current Price',
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getInterval() {
    if (predictionData.length <= 7) return 1;
    if (predictionData.length <= 30) return 5;
    return 10;
  }

  double _getPriceInterval(double min, double max) {
    final range = max - min;
    if (range <= 10) return 1;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    if (range <= 500) return 50;
    if (range <= 1000) return 100;
    if (range <= 5000) return 500;
    if (range <= 10000) return 1000;
    return 5000;
  }

  String _formatDate(DateTime date) {
    switch (timeframe) {
      case 'Week':
        return DateFormat('E, MMM d').format(date);
      case 'Month':
        return DateFormat('MMM d').format(date);
      case '3 Months':
      case '6 Months':
        return DateFormat('MMM d').format(date);
      case 'Year':
        return DateFormat('MMM yyyy').format(date);
      default:
        return DateFormat('MMM d').format(date);
    }
  }
}

