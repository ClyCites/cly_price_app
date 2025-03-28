import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/models.dart';
import '../../core/providers/product_provider.dart';
import '../../core/models/product.dart';
import '../../core/providers/market_provider.dart';
import '../../core/theme/app_colors.dart';
import '../common/widgets/loading_indicator.dart';
import '../common/widgets/error_view.dart';
import '../common/widgets/empty_state.dart';
import 'widgets/market_comparison_chart.dart';
import 'widgets/market_list.dart';
import 'add_market_screen.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({Key? key}) : super(key: key);

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  String _selectedProduct = '';
  String _productId = '';
  List<Map<String, dynamic>> _marketComparisons = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (productProvider.products.isNotEmpty) {
      setState(() {
        _selectedProduct = productProvider.products.first.name;
        _productId = productProvider.products.first.id;
        _isLoading = true;
      });
      
      await _loadMarketComparisons();
    }
  }

  Future<void> _loadMarketComparisons() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final comparisons = await Provider.of<ProductProvider>(context, listen: false)
          .apiService
          .compareMarketPrices(_productId);
      
      setState(() {
        _marketComparisons = comparisons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load market comparisons: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onProductChanged(String product) {
    setState(() {
      _selectedProduct = product;
    });
    _loadMarketComparisons();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final List<Product> products = productProvider.products;
    
    if (products.isEmpty) {
      return const Center(
        child: Text('No products available'),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Add Market button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Markets',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddMarketScreen(),
                        ),
                      );
                      
                      if (result == true) {
                        // Refresh markets list
                        final marketProvider = Provider.of<MarketProvider>(context, listen: false);
                        marketProvider.fetchMarkets(forceRefresh: true);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Market'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Product selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProduct.isEmpty ? products.first.name : _selectedProduct,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Market comparison content
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
        onRetry: _loadMarketComparisons,
      );
    }
    
    if (_marketComparisons.isEmpty) {
      return const EmptyState(
        icon: Icons.storefront_outlined,
        title: 'No Market Data',
        message: 'There is no market comparison data available for this product.',
      );
    }
    
    return Column(
      children: [
        // Market comparison chart
        Expanded(
          flex: 2,
          child: MarketComparisonChart(
            data: _marketComparisons,
            product: _selectedProduct,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Market list
        Expanded(
          flex: 3,
          child: MarketList(
            markets: [], // Add the appropriate list of markets here
            onMarketSelected: (market) {
              // Handle market selection here
            },
          ),
        ),
      ],
    );
  }
}

