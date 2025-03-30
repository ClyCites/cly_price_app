import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../core/models/price_alert_model.dart';
import '../../core/models/product.dart';
import '../../core/providers/price_alert_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/market_provider.dart';
import '../../core/models/market_model.dart';
import '../../core/theme/app_colors.dart';
import '../common/widgets/loading_indicator.dart';

class AddAlertScreen extends StatefulWidget {
  final String? productId;
  final String? marketId;
  final PriceAlert? existingAlert;

  const AddAlertScreen({
    Key? key,
    this.productId,
    this.marketId,
    this.existingAlert,
  }) : super(key: key);

  @override
  State<AddAlertScreen> createState() => _AddAlertScreenState();
}

class _AddAlertScreenState extends State<AddAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedProductId = '';
  String _selectedProductName = '';
  String? _selectedMarketId;
  String? _selectedMarketName;
  double _targetPrice = 0.0;
  AlertType _alertType = AlertType.below;
  AlertFrequency _frequency = AlertFrequency.once;
  
  final _priceController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  void _initializeData() {
    // Check if we're editing an existing alert
    if (widget.existingAlert != null) {
      _isEditing = true;
      _selectedProductId = widget.existingAlert!.productId;
      _selectedProductName = widget.existingAlert!.productName;
      _selectedMarketId = widget.existingAlert!.marketId;
      _selectedMarketName = widget.existingAlert!.marketName;
      _targetPrice = widget.existingAlert!.targetPrice;
      _alertType = widget.existingAlert!.alertType;
      _frequency = widget.existingAlert!.frequency;
      _priceController.text = _targetPrice.toString();
    } else if (widget.productId != null) {
      // If a product ID was passed, use it
      _selectedProductId = widget.productId!;
      
      // Get the product name
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        final product = productProvider.products.firstWhere(
          (p) => p.id == _selectedProductId,
          orElse: () => Product(
            id: '',
            name: '',
            category: '',
            description: '',
            productType: '',
            defaultUnit: '',
            currentPrice: 0,
          ),
        );
        
        if (product.id.isNotEmpty) {
          setState(() {
            _selectedProductName = product.name;
          });
        }
      });
    }
    
    // If a market ID was passed, use it
    if (widget.marketId != null) {
      _selectedMarketId = widget.marketId;
      
      // Get the market name
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final marketProvider = Provider.of<MarketProvider>(context, listen: false);
        final market = marketProvider.markets.firstWhere(
          (m) => m.id == _selectedMarketId,
          orElse: () => Market(id: '', name: '', location: ''),
        );
        
        if (market != null) {
          setState(() {
            _selectedMarketName = market.name;
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
  
  Future<void> _saveAlert() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final alertProvider = Provider.of<PriceAlertProvider>(context, listen: false);
      
      // Parse the target price
      _targetPrice = double.tryParse(_priceController.text) ?? 0.0;
      
      if (_isEditing) {
        // Update existing alert
        final updatedAlert = widget.existingAlert!.copyWith(
          productId: _selectedProductId,
          productName: _selectedProductName,
          marketId: _selectedMarketId,
          marketName: _selectedMarketName,
          targetPrice: _targetPrice,
          alertType: _alertType,
          frequency: _frequency,
        );
        
        await alertProvider.updateAlert(updatedAlert);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create new alert
        final newAlert = PriceAlert(
          id: const Uuid().v4(),
          productId: _selectedProductId,
          productName: _selectedProductName,
          marketId: _selectedMarketId,
          marketName: _selectedMarketName,
          targetPrice: _targetPrice,
          alertType: _alertType,
          frequency: _frequency,
          isActive: true,
          createdAt: DateTime.now(),
          userId: 'user_id', // In a real app, get this from auth provider
        );
        
        await alertProvider.createAlert(newAlert);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isEditing ? 'update' : 'create'} alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final marketProvider = Provider.of<MarketProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Price Alert' : 'Create Price Alert'),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditing ? 'Edit Price Alert' : 'Create Price Alert',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get notified when prices meet your criteria',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Product Selection
                    Text(
                      'Product',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_basket),
                      ),
                      value: _selectedProductId.isNotEmpty && productProvider.products.any((p) => p.id == _selectedProductId)
                          ? _selectedProductId
                          : null,
                      items: productProvider.products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product.id,
                          child: Text(product.name),
                        );
                      }).toList(),
                      onChanged: _isEditing ? null : (value) {
                        if (value != null) {
                          final product = productProvider.products.firstWhere(
                            (p) => p.id == value,
                          );
                          setState(() {
                            _selectedProductId = value;
                            _selectedProductName = product.name;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Market Selection (Optional)
                    Text(
                      'Market (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: 'Select Market (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storefront),
                        hintText: 'All Markets',
                      ),
                      value: _selectedMarketId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Markets'),
                        ),
                        ...marketProvider.markets.map((market) {
                          return DropdownMenuItem<String?>(
                            value: market.id,
                            child: Text(market.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMarketId = value;
                          _selectedMarketName = value != null
                              ? marketProvider.markets.firstWhere(
                                  (m) => m.id == value,
                                  orElse: () => Market(id: '', name: '', location: ''),
                                ).name
                              : null;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Alert Criteria
                    Text(
                      'Alert Criteria',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Alert Type
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<AlertType>(
                            decoration: const InputDecoration(
                              labelText: 'Alert Type',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.notifications),
                            ),
                            value: _alertType,
                            items: AlertType.values.map((type) {
                              String label;
                              switch (type) {
                                case AlertType.below:
                                  label = 'Price falls below';
                                  break;
                                case AlertType.above:
                                  label = 'Price rises above';
                                  break;
                                case AlertType.change:
                                  label = 'Price changes by';
                                  break;
                              }
                              return DropdownMenuItem<AlertType>(
                                value: type,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _alertType = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Target Price (UGX)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Alert Frequency
                    Text(
                      'Alert Frequency',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<AlertFrequency>(
                            title: const Text('Once'),
                            value: AlertFrequency.once,
                            groupValue: _frequency,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _frequency = value;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<AlertFrequency>(
                            title: const Text('Always'),
                            value: AlertFrequency.always,
                            groupValue: _frequency,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _frequency = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _frequency == AlertFrequency.once
                          ? 'Alert will trigger once and then deactivate'
                          : 'Alert will trigger every time the condition is met',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveAlert,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Update Alert' : 'Create Alert',
                          style: const TextStyle(
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
    );
  }
}

