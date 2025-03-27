import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/models/price_data.dart';
import '../../../core/theme/app_colors.dart';

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
              'No price data available',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getPriceInterval(),
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
                if (value.toInt() >= priceData.length || value.toInt() < 0) {
                  return const SizedBox();
                }
                final date = priceData[value.toInt()].date;
                return SideTitleWidget(
                  meta: meta,
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
              interval: _getPriceInterval(),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
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
        maxX: priceData.length - 1.0,
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _getSpots(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: priceData.length < 15,
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
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                final data = priceData[index];
                return LineTooltipItem(
                  '${_formatDate(data.date)}\n',
                  const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: NumberFormat.currency(
                        symbol: 'UGX ',
                        decimalDigits: 0,
                      ).format(data.price),
                      style: const TextStyle(
                        color: AppColors.primary,
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
    if (range <= 1000) return 100;
    if (range <= 5000) return 500;
    if (range <= 10000) return 1000;
    return 5000;
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
        return DateFormat('MMM d').format(date);
      case 'Year':
        return DateFormat('MMM').format(date);
      default:
        return DateFormat('MMM d').format(date);
    }
  }
}

