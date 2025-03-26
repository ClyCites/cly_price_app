import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/market_provider.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/price_chart.dart';
import 'widgets/price_summary.dart';
import 'widgets/product_selector.dart';
import 'widgets/trending_products.dart';
import 'widgets/market_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedProduct = '';
  String _selectedTimeframe = 'Week';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Update the _initializeData method to ensure we have a valid product name
  Future<void> _initializeData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);
    
    // First fetch markets to populate the list
    await marketProvider.fetchMarkets();
    
    // Then fetch products if needed
    if (productProvider.products.isEmpty) {
      await productProvider.fetchProducts();
    }
    
    // Only set selected product if we have products and it's not already set
    if (productProvider.products.isNotEmpty && _selectedProduct.isEmpty) {
      setState(() {
        _selectedProduct = productProvider.products.first.name;
      });
      
      // Now fetch price data and market data with a valid product name
      await productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
      await marketProvider.fetchMarketsByProduct(_selectedProduct);
    }
  }

  Future<void> _refreshData() async {
    if (_selectedProduct.isNotEmpty) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final marketProvider = Provider.of<MarketProvider>(context, listen: false);
      
      await productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
      await marketProvider.fetchMarkets(forceRefresh: true);
    }
  }

  void _onProductChanged(String product) {
    setState(() {
      _selectedProduct = product;
    });
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
  }

  void _onTimeframeChanged(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    if (_selectedProduct.isEmpty && productProvider.products.isNotEmpty) {
      setState(() {
        _selectedProduct = productProvider.products.first.name;
      });
    }
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Selector
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                  ),
                ],
                child: ProductSelector(
                  products: productProvider.products.map((p) => p.name).toList(),
                  selectedProduct: _selectedProduct,
                  onProductChanged: _onProductChanged,
                ),
              ),
              const SizedBox(height: 16),
              
              // Price Chart Card
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 200),
                  ),
                  SlideEffect(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 200),
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
                              'Price Analytics',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedTimeframe,
                              underline: const SizedBox(),
                              items: AppConstants.timeframes.map((timeframe) {
                                return DropdownMenuItem(
                                  value: timeframe,
                                  child: Text(timeframe),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _onTimeframeChanged(value);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Price Summary
                        PriceSummary(
                          product: _selectedProduct,
                          currentPrice: productProvider.currentPrice,
                          priceChange: productProvider.priceChange,
                          priceChangePercentage: productProvider.priceChangePercentage,
                        ),
                        const SizedBox(height: 24),
                        
                        // Price Chart
                        SizedBox(
                          height: 300,
                          child: productProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : PriceChart(
                                  priceData: productProvider.priceData,
                                  product: _selectedProduct,
                                  timeframe: _selectedTimeframe,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Market Summary
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 300),
                  ),
                  SlideEffect(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 300),
                  ),
                ],
                child: MarketSummary(
                  productName: _selectedProduct,
                ),
              ),
              const SizedBox(height: 24),
              
              // Trending Products
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 400),
                  ),
                  SlideEffect(
                    begin: Offset(0, 0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 400),
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trending Products',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TrendingProducts(
                      products: productProvider.trendingProducts,
                      onProductSelected: _onProductChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

