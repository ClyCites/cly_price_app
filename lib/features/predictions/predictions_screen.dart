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
    final size = MediaQuery.of(context).size;
    
    // Responsive text sizes
    final titleSize = size.width * 0.04;
    final labelSize = size.width * 0.035;
    final inputTextSize = size.width * 0.035;
    
    // Responsive spacing
    final padding = size.width * 0.04;
    final spacing = size.height * 0.015;
    final inputPadding = EdgeInsets.symmetric(
      horizontal: size.width * 0.04,
      vertical: size.height * 0.01,
    );
    
    if (products.isEmpty || markets.isEmpty) {
      return Center(
        child: Text(
          'No products or markets available',
          style: TextStyle(fontSize: labelSize),
        ),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
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
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Prediction',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing),
                      
                      // Product selector
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Product',
                          labelStyle: TextStyle(fontSize: labelSize),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: inputPadding,
                          isDense: true,
                        ),
                        value: _selectedProduct,
                        style: TextStyle(
                          fontSize: inputTextSize,
                          color: Colors.black87,
                        ),
                        icon: Icon(Icons.arrow_drop_down, size: size.width * 0.06),
                        isExpanded: true,
                        items: products.map((Product product) {
                          return DropdownMenuItem<String>(
                            value: product.name,
                            child: Text(
                              product.name,
                              style: TextStyle(fontSize: inputTextSize),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _onProductChanged(newValue);
                          }
                        },
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Market selector
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Market',
                          labelStyle: TextStyle(fontSize: labelSize),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: inputPadding,
                          isDense: true,
                        ),
                        value: _selectedMarket,
                        style: TextStyle(
                          fontSize: inputTextSize,
                          color: Colors.black87,
                        ),
                        icon: Icon(Icons.arrow_drop_down, size: size.width * 0.06),
                        isExpanded: true,
                        items: markets.map((String market) {
                          return DropdownMenuItem<String>(
                            value: market,
                            child: Text(
                              market,
                              style: TextStyle(fontSize: inputTextSize),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _onMarketChanged(newValue);
                          }
                        },
                      ),
                      
                      SizedBox(height: spacing),
                      
                      // Timeframe selector
                      Row(
                        children: _timeframes.map((timeframe) {
                          final isSelected = _selectedTimeframe == timeframe;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                              child: ChoiceChip(
                                label: Text(
                                  timeframe,
                                  style: TextStyle(
                                    fontSize: inputTextSize * 0.9,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade700,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _onTimeframeChanged(timeframe);
                                  }
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.01,
                                  vertical: size.height * 0.005,
                                ),
                                labelPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.01,
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
              
              SizedBox(height: spacing),
              
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
    final size = MediaQuery.of(context).size;
    
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
      return EmptyState(
        icon: Icons.trending_up_outlined,
        title: 'No Prediction Data',
        message: 'There is no prediction data available for this selection.',
      );
    }
    
    // Use LayoutBuilder to adapt to available space
    return LayoutBuilder(
      builder: (context, constraints) {
        // For very small heights, use a scrollable layout
        if (constraints.maxHeight < size.height * 0.4) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.35,
                  child: PredictionChart(
                    prediction: _prediction!,
                    productName: _selectedProduct,
                    marketName: _selectedMarket,
                    timeframe: _selectedTimeframe,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                SizedBox(
                  height: size.height * 0.25,
                  child: PredictionFactors(
                    prediction: _prediction!,
                    productName: _selectedProduct,
                    marketName: _selectedMarket,
                  ),
                ),
              ],
            ),
          );
        }
        
        // For normal heights, use a flex layout
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
            
            SizedBox(height: size.height * 0.015),
            
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
      },
    );
  }
}

