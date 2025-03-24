import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../providers/product_provider.dart';
import '../models/price_entry.dart';
import '../utils/validators.dart';
import '../widgets/common/loading_overlay.dart';

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
  
  List<String> _productSuggestions = [];
  List<String> _marketSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadProductSuggestions();
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

  Future<void> _loadProductSuggestions() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts();
    
    if (mounted) {
      setState(() {
        _productSuggestions = productProvider.products.map((p) => p.name).toList();
        // Get unique markets from the provider
        _marketSuggestions = productProvider.markets;
      });
    }
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
          id: '',
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
              backgroundColor: Colors.green,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Price Data'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Agricultural Product Price',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your contribution helps farmers and traders make better decisions.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                
                // Product Selection
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _productSuggestions.where((option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _productController.text = selection;
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    _productController.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g., Rice, Wheat, Corn',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.agriculture),
                      ),
                      validator: Validators.required('Product name is required'),
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Market Selection
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _marketSuggestions.where((option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _marketController.text = selection;
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    _marketController.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Market',
                        hintText: 'e.g., Kampala Central Market',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storefront),
                      ),
                      validator: Validators.required('Market is required'),
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Product Type and Category
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Product Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _selectedProductType,
                        items: const [
                          DropdownMenuItem(value: 'solid', child: Text('Solid')),
                          DropdownMenuItem(value: 'liquid', child: Text('Liquid')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedProductType = value;
                              // Update unit based on product type
                              _selectedUnit = value == 'solid' ? 'kg' : 'liters';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label),
                        ),
                        value: _selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'grain', child: Text('Grain')),
                          DropdownMenuItem(value: 'vegetable', child: Text('Vegetable')),
                          DropdownMenuItem(value: 'fruit', child: Text('Fruit')),
                          DropdownMenuItem(value: 'meat', child: Text('Meat')),
                          DropdownMenuItem(value: 'beverage', child: Text('Beverage')),
                        ],
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
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (UGX)',
                          hintText: 'e.g., 25000',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.required('Price is required'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity (${_selectedUnit})',
                          hintText: 'e.g., 50',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.scale),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.required('Quantity is required'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Date Selection
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Location
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'e.g., Kampala, Uganda',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: Validators.required('Location is required'),
                        enabled: !_useCurrentLocation,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Switch(
                      value: _useCurrentLocation,
                      onChanged: (value) {
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
                    const Text('Use current'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Any additional information about the price or product',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Submit Price Data',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

