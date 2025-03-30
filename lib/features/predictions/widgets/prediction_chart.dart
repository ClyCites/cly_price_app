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
    final size = MediaQuery.of(context).size;
    final currentPrice = prediction['currentPrice'] as double? ?? 0;
    final predictedPrice = prediction['predictedPrice'] as double? ?? 0;
    final historicalPrices = prediction['historicalPrices'] as List<dynamic>? ?? [];
    
    // Calculate price change
    final priceChange = predictedPrice - currentPrice;
    final priceChangePercentage = currentPrice != 0 ? (priceChange / currentPrice) * 100 : 0;
    
    // Responsive text sizes
    final titleSize = size.width * 0.04;
    final subtitleSize = size.width * 0.03;
    final valueSize = size.width * 0.04;
    final smallTextSize = size.width * 0.028;
    
    // Responsive spacing
    final padding = size.width * 0.04;
    final spacing = size.height * 0.015;
    
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$productName Price Prediction',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing * 0.3),
                      Text(
                        '$marketName - $timeframe forecast',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.height * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriceChangeColor(priceChangePercentage.toDouble()).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        priceChangePercentage >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: smallTextSize,
                        color: _getPriceChangeColor(priceChangePercentage.toDouble()),
                      ),
                      SizedBox(width: size.width * 0.01),
                      Text(
                        '${priceChangePercentage >= 0 ? '+' : ''}${priceChangePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: smallTextSize,
                          color: _getPriceChangeColor(priceChangePercentage.toDouble()),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spacing),
            
            // Price summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceBox(
                  context,
                  'Current Price',
                  '${currentPrice.toStringAsFixed(2)} UGX',
                  Colors.blue.shade100,
                  Colors.blue.shade800,
                ),
                _buildPriceBox(
                  context,
                  'Predicted Price',
                  '${predictedPrice.toStringAsFixed(2)} UGX',
                  _getPriceChangeColor(priceChangePercentage.toDouble()).withOpacity(0.2),
                  _getPriceChangeColor(priceChangePercentage.toDouble()),
                ),
              ],
            ),
            
            SizedBox(height: spacing),
            
            // Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final index = barSpot.x.toInt();
                          if (index < 0 || index >= _getChartData().length) {
                            return null;
                          }
                          
                          final data = _getChartData()[index];
                          final date = data['date'] as DateTime;
                          final price = data['price'] as double;
                          final isHistorical = data['isHistorical'] as bool;
                          
                          return LineTooltipItem(
                            '${DateFormat('MMM d, yyyy').format(date)}\n',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: smallTextSize,
                            ),
                            children: [
                              TextSpan(
                                text: 'UGX ${price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isHistorical ? Colors.blue.shade200 : Colors.green.shade200,
                                  fontWeight: FontWeight.bold,
                                  fontSize: smallTextSize,
                                ),
                              ),
                              TextSpan(
                                text: '\n${isHistorical ? 'Historical' : 'Predicted'}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: smallTextSize * 0.8,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
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
                        reservedSize: size.height * 0.04,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _getChartData().length) {
                            return const SizedBox.shrink();
                          }
                          
                          // Only show some dates to avoid overcrowding
                          // Adjust the modulo based on screen width
                          final modulo = size.width < 360 ? 3 : 2;
                          if (index % modulo != 0 && index != _getChartData().length - 1) {
                            return const SizedBox.shrink();
                          }
                          
                          final date = _getChartData()[index]['date'] as DateTime;
                          return Padding(
                            padding: EdgeInsets.only(top: size.height * 0.01),
                            child: Text(
                              DateFormat('MMM d').format(date),
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: smallTextSize * 0.9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: size.width * 0.1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: smallTextSize * 0.9,
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
                      barWidth: size.width * 0.006,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: _getHistoricalDataCount() < 10,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: size.width * 0.01,
                            color: Colors.blue,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
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
                      barWidth: size.width * 0.006,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: (_getChartData().length - _getHistoricalDataCount()) < 10,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: size.width * 0.01,
                            color: _getPriceChangeColor(priceChangePercentage.toDouble()),
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
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
            
            SizedBox(height: spacing * 0.5),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  context,
                  'Historical',
                  Colors.blue,
                ),
                SizedBox(width: size.width * 0.04),
                _buildLegendItem(
                  context,
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

  Widget _buildPriceBox(BuildContext context, String label, String value, Color bgColor, Color textColor) {
    final size = MediaQuery.of(context).size;
    final labelSize = size.width * 0.03;
    final valueSize = size.width * 0.04;
    
    return Container(
      width: size.width * 0.4,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: textColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: size.height * 0.004),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, {bool isDashed = false}) {
    final size = MediaQuery.of(context).size;
    final textSize = size.width * 0.028;
    
    return Row(
      children: [
        Container(
          width: size.width * 0.04,
          height: size.height * 0.003,
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
        SizedBox(width: size.width * 0.01),
        Text(
          label,
          style: TextStyle(
            fontSize: textSize,
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

