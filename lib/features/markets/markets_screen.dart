import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/market_comparison_chart.dart';
import 'widgets/market_list.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  String _selectedProduct = '';
  List<Map<String, dynamic>> _marketComparison = [];
  bool _isLoading = false;

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
      
      await _fetchMarketComparison();
    }
  }

  Future<void> _fetchMarketComparison() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final comparison = await productProvider.compareMarketPrices(_selectedProduct);
      
      setState(() {
        _marketComparison = comparison;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch market comparison: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onProductChanged(String product) {
    setState(() {
      _selectedProduct = product;
    });
    _fetchMarketComparison();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return SingleChildScrollView(
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProduct,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    items: productProvider.products.map((product) {
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
            ),
            const SizedBox(height: 24),
            
            // Market Comparison Chart
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
                      Text(
                        'Market Price Comparison',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : MarketComparisonChart(
                                data: _marketComparison,
                                product: _selectedProduct,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Market List
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
                    'Markets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MarketList(
                    markets: productProvider.markets,
                    onMarketSelected: (market) {
                      // TODO: Implement market details navigation
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

