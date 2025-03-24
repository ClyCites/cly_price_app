import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/prediction_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/prediction_chart.dart';
import 'widgets/prediction_factors.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  String _selectedProduct = '';
  String _selectedMarket = '';
  String _selectedTimeframe = 'Month';
  bool _predictionGenerated = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (productProvider.products.isNotEmpty && _selectedProduct.isEmpty) {
      setState(() {
        _selectedProduct = productProvider.products.first.name;
      });
    }
    
    if (productProvider.markets.isNotEmpty && _selectedMarket.isEmpty) {
      setState(() {
        _selectedMarket = productProvider.markets.first;
      });
    }
  }

  Future<void> _generatePrediction() async {
    final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
    
    try {
      await predictionProvider.generatePrediction(
        _selectedProduct,
        _selectedMarket,
        _selectedTimeframe,
      );
      
      setState(() {
        _predictionGenerated = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate prediction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final predictionProvider = Provider.of<PredictionProvider>(context);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prediction Form
            Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 600)),
                SlideEffect(
                  begin: Offset(0, 0.1),
                  end: Offset.zero,
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Price Prediction',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a product, market, and timeframe to generate an AI-powered price prediction',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Product Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Product',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.agriculture_outlined),
                        ),
                        value: _selectedProduct,
                        items: productProvider.products.map((product) {
                          return DropdownMenuItem(
                            value: product.name,
                            child: Text(product.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedProduct = value;
                              _predictionGenerated = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Market Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Market',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.storefront_outlined),
                        ),
                        value: _selectedMarket,
                        items: productProvider.markets.map((market) {
                          return DropdownMenuItem(
                            value: market,
                            child: Text(market),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMarket = value;
                              _predictionGenerated = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Timeframe Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Prediction Timeframe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        value: _selectedTimeframe,
                        items: AppConstants.predictionTimeframes.map((timeframe) {
                          return DropdownMenuItem(
                            value: timeframe,
                            child: Text(timeframe),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTimeframe = value;
                              _predictionGenerated = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: predictionProvider.isLoading ? null : _generatePrediction,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: predictionProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Generate Prediction',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Prediction Results
            if (_predictionGenerated && !predictionProvider.isLoading && predictionProvider.predictionData.isNotEmpty)
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                  ),
                ],
                child: Card(
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
                            Text(
                              'Price Prediction',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Generated: ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI-powered price forecast for $_selectedProduct in $_selectedMarket over the next $_selectedTimeframe',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Prediction Chart
                        SizedBox(
                          height: 300,
                          child: PredictionChart(
                            predictionData: predictionProvider.predictionData,
                            product: _selectedProduct,
                            timeframe: _selectedTimeframe,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Prediction Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPredictionSummaryItem(
                                context,
                                'Current',
                                NumberFormat.currency(
                                  symbol: 'UGX ',
                                  decimalDigits: 0,
                                ).format(predictionProvider.currentPrice),
                                Icons.attach_money,
                                AppColors.accent,
                              ),
                              _buildPredictionSummaryItem(
                                context,
                                'Predicted',
                                NumberFormat.currency(
                                  symbol: 'UGX ',
                                  decimalDigits: 0,
                                ).format(predictionProvider.predictedPrice),
                                Icons.trending_up,
                                AppColors.primary,
                              ),
                              _buildPredictionSummaryItem(
                                context,
                                'Change',
                                '${predictionProvider.predictedChangePercentage.toStringAsFixed(1)}%',
                                predictionProvider.predictedChangePercentage >= 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                predictionProvider.predictedChangePercentage >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Prediction Factors
                        Text(
                          'Factors Influencing Prediction',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PredictionFactors(
                          factors: predictionProvider.predictionFactors,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMedium,
          ),
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

