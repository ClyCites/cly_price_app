import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class PredictionChart extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final String productName;
  final String marketName;
  final String timeframe;

  const PredictionChart({
    Key? key,
    required this.prediction,
    required this.productName,
    required this.marketName,
    required this.timeframe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPrice = prediction['currentPrice'] as double? ?? 0;
    final predictedPrice = prediction['predictedPrice'] as double? ?? 0;
    final historicalPrices = prediction['historicalPrices'] as List<dynamic>? ?? [];
    
    // Calculate price change
    final priceChange = predictedPrice - currentPrice;
    final priceChangePercentage = currentPrice != 0 ? (priceChange / currentPrice) * 100 : 0;
    
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$productName Price Prediction',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$marketName - $timeframe forecast',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPriceChangeColor(priceChangePercentage.toDouble()).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        priceChangePercentage >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: _getPriceChangeColor(priceChangePercentage.toDouble()),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${priceChangePercentage >= 0 ? '+' : ''}${priceChangePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getPriceChangeColor(priceChangePercentage.toDouble()),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Price summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceBox(
                  'Current Price',
                  '${currentPrice.toStringAsFixed(2)} UGX',
                  Colors.blue.shade100,
                  Colors.blue.shade800,
                ),
                _buildPriceBox(
                  'Predicted Price',
                  '${predictedPrice.toStringAsFixed(2)} UGX',
                  _getPriceChangeColor(priceChangePercentage.toDouble()).withOpacity(0.2),
                  _getPriceChangeColor(priceChangePercentage.toDouble()),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                    ),
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {},
                    handleBuiltInTouches: true,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _getChartData().length) {
                            return const SizedBox.shrink();
                          }
                          
                          // Only show some dates to avoid overcrowding
                          if (index % 2 != 0 && index != _getChartData().length - 1) {
                            return const SizedBox.shrink();
                          }
                          
                          final date = _getChartData()[index]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MMM d').format(date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      left: BorderSide(color: Colors.grey.shade300, width: 1),
                      right: BorderSide(color: Colors.grey.shade300, width: 0),
                      top: BorderSide(color: Colors.grey.shade300, width: 0),
                    ),
                  ),
                  minX: 0,
                  maxX: _getChartData().length.toDouble() - 1,
                  minY: _getMinY(),
                  maxY: _getMaxY(),
                  lineBarsData: [
                    // Historical data
                    LineChartBarData(
                      spots: List.generate(_getHistoricalDataCount(), (index) {
                        return FlSpot(
                          index.toDouble(),
                          _getChartData()[index]['price'] as double,
                        );
                      }),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    // Prediction data
                    LineChartBarData(
                      spots: List.generate(
                        _getChartData().length - _getHistoricalDataCount(),
                        (index) {
                          final dataIndex = index + _getHistoricalDataCount();
                          return FlSpot(
                            dataIndex.toDouble(),
                            _getChartData()[dataIndex]['price'] as double,
                          );
                        },
                      ),
                      isCurved: true,
                      color: _getPriceChangeColor(priceChangePercentage.toDouble()),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getPriceChangeColor(priceChangePercentage.toDouble()).withOpacity(0.1),
                      ),
                      dashArray: [5, 5], // Make the prediction line dashed
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Historical', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem(
                  'Predicted',
                  _getPriceChangeColor(priceChangePercentage.toDouble()),
                  isDashed: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBox(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: isDashed
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        (constraints.constrainWidth() / 3).floor(),
                        (index) => SizedBox(
                          width: 2,
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: color),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getPriceChangeColor(double priceChangePercentage) {
    if (priceChangePercentage > 0) {
      return Colors.green;
    } else if (priceChangePercentage < 0) {
      return Colors.red;
    }
    return Colors.orange;
  }

  List<Map<String, dynamic>> _getChartData() {
    final List<Map<String, dynamic>> chartData = [];
    
    // Add historical data
    final historicalPrices = prediction['historicalPrices'] as List<dynamic>? ?? [];
    for (final price in historicalPrices) {
      chartData.add({
        'date': DateTime.parse(price['date'] as String),
        'price': price['price'] as double,
        'isHistorical': true,
      });
    }
    
    // Add current price
    final currentPrice = prediction['currentPrice'] as double? ?? 0;
    chartData.add({
      'date': DateTime.now(),
      'price': currentPrice,
      'isHistorical': true,
    });
    
    // Add prediction data
    final predictedPrice = prediction['predictedPrice'] as double? ?? 0;
    final predictionDate = prediction['predictionDate'] != null
        ? DateTime.parse(prediction['predictionDate'] as String)
        : _getFutureDateBasedOnTimeframe();
    
    // Add intermediate points for a smoother curve
    final daysBetween = predictionDate.difference(DateTime.now()).inDays;
    final step = daysBetween ~/ 5; // 5 intermediate points
    
    for (int i = 1; i <= 5; i++) {
      final date = DateTime.now().add(Duration(days: step * i));
      final progress = i / 5;
      final interpolatedPrice = currentPrice + (predictedPrice - currentPrice) * progress;
      
      chartData.add({
        'date': date,
        'price': interpolatedPrice,
        'isHistorical': false,
      });
    }
    
    // Add final prediction
    chartData.add({
      'date': predictionDate,
      'price': predictedPrice,
      'isHistorical': false,
    });
    
    return chartData;
  }

  int _getHistoricalDataCount() {
    final historicalPrices = prediction['historicalPrices'] as List<dynamic>? ?? [];
    // +1 for the current price
    return historicalPrices.length + 1;
  }

  double _getMinY() {
    double minPrice = double.infinity;
    for (final data in _getChartData()) {
      final price = data['price'] as double;
      if (price < minPrice) {
        minPrice = price;
      }
    }
    // Add some padding
    return (minPrice * 0.9).floorToDouble();
  }

  double _getMaxY() {
    double maxPrice = 0;
    for (final data in _getChartData()) {
      final price = data['price'] as double;
      if (price > maxPrice) {
        maxPrice = price;
      }
    }
    // Add some padding
    return (maxPrice * 1.1).ceilToDouble();
  }

  DateTime _getFutureDateBasedOnTimeframe() {
    switch (timeframe) {
      case 'Week':
        return DateTime.now().add(const Duration(days: 7));
      case 'Month':
        return DateTime.now().add(const Duration(days: 30));
      case 'Quarter':
        return DateTime.now().add(const Duration(days: 90));
      default:
        return DateTime.now().add(const Duration(days: 30));
    }
  }
}

