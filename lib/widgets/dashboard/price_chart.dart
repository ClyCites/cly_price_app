import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../models/price_data.dart';

class PriceChart extends StatelessWidget {
  final List<PriceData> priceData;
  final String product;
  final String timeframe;

  const PriceChart({
    super.key,
    required this.priceData,
    required this.product,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    if (priceData.isEmpty) {
      return const Center(
        child: Text('No price data available'),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor,
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
                  if (value.toInt() >= priceData.length || value.toInt() < 0) {
                    return const SizedBox();
                  }
                  final date = priceData[value.toInt()].date;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getPriceInterval(),
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '\$${value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 10,
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
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          minX: 0,
          maxX: priceData.length - 1.0,
          minY: _getMinY(),
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Theme.of(context).colorScheme.surface,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  final data = priceData[index];
                  return LineTooltipItem(
                    '${_formatDate(data.date)}\n',
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '\$${data.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return priceData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.price);
    }).toList();
  }

  double _getMinY() {
    if (priceData.isEmpty) return 0;
    final min = priceData.map((data) => data.price).reduce((a, b) => a < b ? a : b);
    return (min * 0.9).floorToDouble();
  }

  double _getMaxY() {
    if (priceData.isEmpty) return 100;
    final max = priceData.map((data) => data.price).reduce((a, b) => a > b ? a : b);
    return (max * 1.1).ceilToDouble();
  }

  double _getPriceInterval() {
    final range = _getMaxY() - _getMinY();
    if (range <= 10) return 1;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    if (range <= 500) return 50;
    return 100;
  }

  double _getInterval() {
    if (priceData.length <= 7) return 1;
    if (priceData.length <= 30) return 5;
    return 10;
  }

  String _formatDate(DateTime date) {
    switch (timeframe) {
      case 'Day':
        return DateFormat('HH:mm').format(date);
      case 'Week':
        return DateFormat('E').format(date);
      case 'Month':
        return DateFormat('d').format(date);
      case '3 Months':
      case 'Year':
        return DateFormat('MMM d').format(date);
      default:
        return DateFormat('MMM d').format(date);
    }
  }
}

