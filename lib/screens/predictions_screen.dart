import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/prediction_provider.dart';
import '../widgets/predictions/prediction_chart.dart';
import '../widgets/predictions/prediction_factors.dart';
import '../widgets/common/loading_overlay.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  bool _isLoading = true;
  String _selectedProduct = 'Rice';
  String _selectedTimeframe = 'Month';
  
  final List<String> _products = ['Rice', 'Wheat', 'Corn', 'Soybeans', 'Coffee'];
  final List<String> _timeframes = ['Week', 'Month', '3 Months', '6 Months', 'Year'];

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() {
      _isLoading = true;
    });
    
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
    await predictionProvider.generatePrediction(_selectedProduct, _selectedTimeframe);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionProvider = Provider.of<PredictionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Price Predictions'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Price Prediction',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Product',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedProduct,
                              items: _products.map((product) {
                                return DropdownMenuItem(
                                  value: product,
                                  child: Text(product),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedProduct = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Prediction Timeframe',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedTimeframe,
                              items: _timeframes.map((timeframe) {
                                return DropdownMenuItem(
                                  value: timeframe,
                                  child: Text(timeframe),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedTimeframe = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loadPredictions,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('Generate Prediction'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_isLoading && predictionProvider.predictionData.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price Prediction',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Last updated: ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI-powered price forecast for $_selectedProduct over the next $_selectedTimeframe',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        PredictionChart(
                          predictionData: predictionProvider.predictionData,
                          product: _selectedProduct,
                          timeframe: _selectedTimeframe,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Prediction Summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPredictionSummaryItem(
                              context,
                              'Current',
                              '\$${predictionProvider.currentPrice.toStringAsFixed(2)}',
                              Icons.attach_money,
                              Colors.blue,
                            ),
                            _buildPredictionSummaryItem(
                              context,
                              'Predicted',
                              '\$${predictionProvider.predictedPrice.toStringAsFixed(2)}',
                              Icons.trending_up,
                              Colors.green,
                            ),
                            _buildPredictionSummaryItem(
                              context,
                              'Change',
                              '${predictionProvider.predictedChangePercentage.toStringAsFixed(2)}%',
                              predictionProvider.predictedChangePercentage >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              predictionProvider.predictedChangePercentage >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        PredictionFactors(
                          factors: predictionProvider.predictionFactors,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

