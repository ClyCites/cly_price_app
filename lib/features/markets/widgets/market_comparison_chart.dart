import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class MarketComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String product;

  const MarketComparisonChart({
    super.key,
    required this.data,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
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
              'No market comparison data available',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final maxPrice = data.map((e) => e['price'] as double).reduce((a, b) => a > b ? a : b);
    final minPrice = data.map((e) => e['price'] as double).reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxPrice + (priceRange * 0.1),
        minY: minPrice - (priceRange * 0.1),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final market = data[groupIndex]['market'] as String;
              final price = data[groupIndex]['price'] as double;
              return BarTooltipItem(
                '$market\n',
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
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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
                if (value < 0 || value >= data.length) {
                  return const SizedBox();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    data[value.toInt()]['market'] as String,
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
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
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
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
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade200),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final price = item['price'] as double;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: price,
                color: AppColors.primary,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

