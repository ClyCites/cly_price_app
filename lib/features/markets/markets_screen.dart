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
  String _selectedProductId = '';
  String _selectedProductName = '';
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
      final firstProduct = productProvider.products.first;
      setState(() {
        _selectedProductId = firstProduct.id;
        _selectedProductName = firstProduct.name;
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
      
      final apiService = Provider.of<ProductProvider>(context, listen: false).apiService;
      final comparisons = await apiService.compareMarketPrices(_selectedProductId);
      
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

  void _onProductChanged(String productId, String productName) {
    setState(() {
      _selectedProductId = productId;
      _selectedProductName = productName;
    });
    _loadMarketComparisons();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final List<Product> products = productProvider.products;
    final size = MediaQuery.of(context).size;
    
    // Responsive text sizes
    final titleSize = size.width * 0.05;
    final subtitleSize = size.width * 0.035;
    final buttonTextSize = size.width * 0.035;
    
    // Responsive spacing
    final padding = size.width * 0.04;
    final spacing = size.height * 0.02;
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: size.width * 0.03,
      vertical: size.height * 0.01,
    );
    
    if (products.isEmpty) {
      return Center(
        child: Text(
          'No products available',
          style: TextStyle(fontSize: subtitleSize),
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
              // Header with Add Market button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Markets',
                    style: TextStyle(
                      fontSize: titleSize,
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
                    icon: Icon(Icons.add, size: size.width * 0.04),
                    label: Text(
                      'Add Market',
                      style: TextStyle(fontSize: buttonTextSize),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: spacing * 0.75),
              
              // Product selector
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProductId.isEmpty && products.isNotEmpty 
                        ? products.first.id 
                        : _selectedProductId,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                      size: size.width * 0.06,
                    ),
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    items: products.map((Product product) {
                      return DropdownMenuItem<String>(
                        value: product.id,
                        child: Text(
                          product.name,
                          style: TextStyle(fontSize: subtitleSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Find the product name for the selected ID
                        final selectedProduct = products.firstWhere(
                          (product) => product.id == newValue,
                          orElse: () => products.first,
                        );
                        _onProductChanged(newValue, selectedProduct.name);
                      }
                    },
                  ),
                ),
              ),
              
              SizedBox(height: spacing),
              
              // Market comparison content
              Expanded(
                child: _buildContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
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
                  child: MarketComparisonChart(
                    data: _marketComparisons,
                    product: _selectedProductName,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  height: size.height * 0.4,
                  child: MarketList(
                    marketComparisons: _marketComparisons,
                    onMarketSelected: (market) {
                      // Handle market selection here
                    },
                  ),
                ),
              ],
            ),
          );
        }
        
        // For normal heights, use a flex layout with more space for the chart
        return Column(
          children: [
            // Market comparison chart - give it more space
            Expanded(
              flex: 3, // Increased from 2 to 3
              child: MarketComparisonChart(
                data: _marketComparisons,
                product: _selectedProductName,
              ),
            ),
            
            SizedBox(height: size.height * 0.015),
            
            // Market list
            Expanded(
              flex: 2, // Decreased from 3 to 2
              child: MarketList(
                marketComparisons: _marketComparisons,
                onMarketSelected: (market) {
                  // Handle market selection here
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

