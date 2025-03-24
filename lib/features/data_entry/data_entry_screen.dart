import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/price_entry.dart';
import '../../core/providers/product_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import 'widgets/data_entry_field.dart';
import 'widgets/location_field.dart';
import 'widgets/product_field.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _marketController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _useCurrentLocation = true;
  String? _currentLocation;
  Position? _position;
  
  String _selectedProductType = 'solid';
  String _selectedUnit = 'kg';
  String _selectedCategory = 'grain';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _productController.dispose();
    _marketController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _useCurrentLocation = false;
          _isLoading = false;
        });
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _useCurrentLocation = false;
            _isLoading = false;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _useCurrentLocation = false;
          _isLoading = false;
        });
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _position = position;
          _currentLocation = '${place.locality}, ${place.administrativeArea}, ${place.country}';
          _locationController.text = _currentLocation ?? '';
          
          // If we have a locality, use it as the market
          if (place.locality != null && place.locality!.isNotEmpty) {
            _marketController.text = place.locality!;
          }
        });
      }
    } catch (e) {
      setState(() {
        _useCurrentLocation = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        
        final priceEntry = PriceEntry(
          id: const Uuid().v4(),
          productName: _productController.text,
          market: _marketController.text,
          price: double.parse(_priceController.text),
          currency: 'UGX', // Default currency
          quantity: double.parse(_quantityController.text),
          unit: _selectedUnit,
          productType: _selectedProductType,
          location: _locationController.text,
          latitude: _position?.latitude,
          longitude: _position?.longitude,
          date: _selectedDate,
          notes: _notesController.text,
          status: 'pending',
          category: _selectedCategory,
        );
        
        await productProvider.submitPriceEntry(priceEntry);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Price data submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting data: ${e.toString()}'),
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
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Price Data'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 600)),
                SlideEffect(
                  begin: Offset(0, 0.1),
                  end: Offset.zero,
                  duration: Duration(milliseconds: 600),
                ),
              ],
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
                              Icons.agriculture,
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
                                  'Submit Price Data',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your contribution helps farmers and traders make better decisions',
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
                    ProductField(
                      controller: _productController,
                      products: productProvider.products.map((p) => p.name).toList(),
                      onProductSelected: (product) {
                        final selectedProduct = productProvider.products.firstWhere(
                          (p) => p.name == product,
                          orElse: () => productProvider.products.first,
                        );
                        
                        setState(() {
                          _selectedProductType = selectedProduct.productType;
                          _selectedUnit = selectedProduct.defaultUnit;
                          _selectedCategory = selectedProduct.category;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Market Selection
                    DataEntryField(
                      controller: _marketController,
                      label: 'Market',
                      hintText: 'e.g., Kampala Central Market',
                      prefixIcon: Icons.storefront,
                      validator: Validators.required('Market is required'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Type and Category
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Product Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: const Icon(Icons.category_outlined),
                            ),
                            value: _selectedProductType,
                            items: AppConstants.productTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.capitalize()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedProductType = value;
                                  // Update unit based on product type
                                  _selectedUnit = AppConstants.productTypeUnits[value]?.first ?? 'kg';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: const Icon(Icons.label_outlined),
                            ),
                            value: _selectedCategory,
                            items: AppConstants.productCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.capitalize()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Price and Quantity
                    Row(
                      children: [
                        Expanded(
                          child: DataEntryField(
                            controller: _priceController,
                            label: 'Price (UGX)',
                            hintText: 'e.g., 25000',
                            prefixIcon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validator: Validators.numeric('Please enter a valid price'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DataEntryField(
                            controller: _quantityController,
                            label: 'Quantity ($_selectedUnit)',
                            hintText: 'e.g., 50',
                            prefixIcon: Icons.scale,
                            keyboardType: TextInputType.number,
                            validator: Validators.numeric('Please enter a valid quantity'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Selection
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: DataEntryField(
                          controller: TextEditingController(
                            text: DateFormat('MMMM d, yyyy').format(_selectedDate),
                          ),
                          label: 'Date',
                          hintText: 'Select date',
                          prefixIcon: Icons.calendar_today,
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    LocationField(
                      controller: _locationController,
                      useCurrentLocation: _useCurrentLocation,
                      onToggleLocation: (value) {
                        setState(() {
                          _useCurrentLocation = value;
                          if (value && _currentLocation != null) {
                            _locationController.text = _currentLocation!;
                          } else {
                            _locationController.text = '';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    DataEntryField(
                      controller: _notesController,
                      label: 'Notes (Optional)',
                      hintText: 'Any additional information about the price or product',
                      prefixIcon: Icons.note_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Submit Price Data',
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
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

