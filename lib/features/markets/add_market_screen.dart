import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/models/market_model.dart';
import '../../core/providers/market_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../common/widgets/loading_indicator.dart';

class AddMarketScreen extends StatefulWidget {
  const AddMarketScreen({Key? key}) : super(key: key);

  @override
  State<AddMarketScreen> createState() => _AddMarketScreenState();
}

class _AddMarketScreenState extends State<AddMarketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _regionController = TextEditingController();
  final _countryController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  bool _useCurrentLocation = false;
  Position? _currentPosition;
  
  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        setState(() {
          _isLoading = false;
          _useCurrentLocation = false;
        });
        return;
      }
      
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isLoading = false;
            _useCurrentLocation = false;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied, we cannot request permissions.'),
          ),
        );
        setState(() {
          _isLoading = false;
          _useCurrentLocation = false;
        });
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      
      // Get address from position
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _locationController.text = place.locality ?? place.subLocality ?? '';
          _regionController.text = place.administrativeArea ?? '';
          _countryController.text = place.country ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final marketProvider = Provider.of<MarketProvider>(context, listen: false);
      
      final market = Market(
        id: const Uuid().v4(),
        name: _nameController.text,
        location: _locationController.text,
        region: _regionController.text,
        country: _countryController.text,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        isActive: true,
        lastUpdated: DateTime.now(),
        contactInfo: _contactController.text,
        description: _descriptionController.text,
      );
      
      await marketProvider.addMarket(market);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Market added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add market: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Market'),
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
                              Icons.storefront,
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
                                  'Add New Market',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Provide details about the market to help others find it',
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
                    
                    // Market Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Market Name *',
                        hintText: 'Enter the name of the market',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                      validator: Validators.required('Market name is required'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Section
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Location Details',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Switch(
                                  value: _useCurrentLocation,
                                  onChanged: (value) {
                                    setState(() {
                                      _useCurrentLocation = value;
                                      if (value) {
                                        _getCurrentLocation();
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                            Text(
                              'Use current location',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            
                            // Location
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location/City *',
                                hintText: 'Enter the city or area',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              validator: Validators.required('Location is required'),
                              enabled: !_useCurrentLocation,
                            ),
                            const SizedBox(height: 16),
                            
                            // Region
                            TextFormField(
                              controller: _regionController,
                              decoration: const InputDecoration(
                                labelText: 'Region/State',
                                hintText: 'Enter the region or state',
                                prefixIcon: Icon(Icons.map),
                                border: OutlineInputBorder(),
                              ),
                              enabled: !_useCurrentLocation,
                            ),
                            const SizedBox(height: 16),
                            
                            // Country
                            TextFormField(
                              controller: _countryController,
                              decoration: const InputDecoration(
                                labelText: 'Country *',
                                hintText: 'Enter the country',
                                prefixIcon: Icon(Icons.flag),
                                border: OutlineInputBorder(),
                              ),
                              validator: Validators.required('Country is required'),
                              enabled: !_useCurrentLocation,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Additional Information
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            
                            // Contact Information
                            TextFormField(
                              controller: _contactController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Information',
                                hintText: 'Phone number, email, etc.',
                                prefixIcon: Icon(Icons.contact_phone),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Additional details about the market',
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add Market',
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
    );
  }
}

