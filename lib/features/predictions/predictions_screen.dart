import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/models/product.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import '../common/widgets/loading_indicator.dart';
import '../common/widgets/error_view.dart';
import '../common/widgets/empty_state.dart';
import 'widgets/prediction_chart.dart';
import 'widgets/prediction_factors.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({Key? key}) : super(key: key);

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  String _selectedProduct = '';
  String _selectedMarket = '';
  String _selectedTimeframe = 'Month';
  Map<String, dynamic>? _prediction;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _timeframes = ['Week', 'Month', 'Quarter'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (productProvider.products.isNotEmpty && productProvider.markets.isNotEmpty) {
      setState(() {
        _selectedProduct = productProvider.products.first.name;
        _selectedMarket = productProvider.markets.first;
        _isLoading = true;
      });
      
      await _loadPrediction();
    }
  }

  Future<void> _loadPrediction() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final prediction = await Provider.of<ProductProvider>(context, listen: false)
          .apiService
          .predictPrice(_selectedProduct, _selectedMarket, _selectedTimeframe);
      
      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load prediction: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onProductChanged(String product) {
    setState(() {
      _selectedProduct = product;
    });
    _loadPrediction();
  }

  void _onMarketChanged(String market) {
    setState(() {
      _selectedMarket = market;
    });
    _loadPrediction();
  }

  void _onTimeframeChanged(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    _loadPrediction();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;
    final markets = productProvider.markets;
    
    if (products.isEmpty || markets.isEmpty) {
      return const Center(
        child: Text('No products or markets available'),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Prediction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Product selector
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        value: _selectedProduct,
                        items: products.map((Product product) {
                          return DropdownMenuItem<String>(
                            value: product.name,
                            child: Text(product.name),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _onProductChanged(newValue);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Market selector
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Market',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        value: _selectedMarket,
                        items: markets.map((String market) {
                          return DropdownMenuItem<String>(
                            value: market,
                            child: Text(market),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _onMarketChanged(newValue);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Timeframe selector
                      Row(
                        children: _timeframes.map((timeframe) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(timeframe),
                                selected: _selectedTimeframe == timeframe,
                                onSelected: (selected) {
                                  if (selected) {
                                    _onTimeframeChanged(timeframe);
                                  }
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _selectedTimeframe == timeframe
                                      ? AppColors.primary
                                      : Colors.grey.shade700,
                                  fontWeight: _selectedTimeframe == timeframe
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Prediction content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: _loadPrediction,
      );
    }
    
    if (_prediction == null) {
      return const EmptyState(
        icon: Icons.trending_up_outlined,
        title: 'No Prediction Data',
        message: 'There is no prediction data available for this selection.',
      );
    }
    
    return Column(
      children: [
        // Prediction chart
        Expanded(
          flex: 3,
          child: PredictionChart(
            prediction: _prediction!,
            productName: _selectedProduct,
            marketName: _selectedMarket,
            timeframe: _selectedTimeframe,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Prediction factors
        Expanded(
          flex: 2,
          child: PredictionFactors(
            prediction: _prediction!,
            productName: _selectedProduct,
            marketName: _selectedMarket,
          ),
        ),
      ],
    );
  }
}

