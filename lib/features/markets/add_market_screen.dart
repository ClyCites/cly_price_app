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
    final size = MediaQuery.of(context).size;
    
    // Responsive text sizes
    final titleSize = size.width * 0.045;
    final subtitleSize = size.width * 0.035;
    final labelSize = size.width * 0.035;
    final buttonTextSize = size.width * 0.04;
    
    // Responsive spacing
    final padding = size.width * 0.04;
    final spacing = size.height * 0.02;
    final smallSpacing = size.height * 0.01;
    final iconSize = size.width * 0.06;
    
    // Input decoration
    final inputDecoration = InputDecoration(
      labelStyle: TextStyle(fontSize: labelSize),
      hintStyle: TextStyle(fontSize: labelSize),
      contentPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.015,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Market',
          style: TextStyle(fontSize: titleSize),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(padding * 0.75),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.storefront,
                                color: Colors.white,
                                size: iconSize,
                              ),
                            ),
                            SizedBox(width: size.width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add New Market',
                                    style: TextStyle(
                                      fontSize: subtitleSize * 1.2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: smallSpacing * 0.5),
                                  Text(
                                    'Provide details about the market to help others find it',
                                    style: TextStyle(
                                      fontSize: subtitleSize * 0.9,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing),
                      
                      // Market Name
                      Text(
                        'Market Name *',
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      TextFormField(
                        controller: _nameController,
                        decoration: inputDecoration.copyWith(
                          hintText: 'Enter the name of the market',
                          prefixIcon: Icon(Icons.store, size: iconSize * 0.8),
                        ),
                        style: TextStyle(fontSize: labelSize),
                        validator: Validators.required('Market name is required'),
                      ),
                      SizedBox(height: spacing),
                      
                      // Location Section
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Location Details',
                                    style: TextStyle(
                                      fontSize: subtitleSize * 1.1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Use current location',
                                        style: TextStyle(
                                          fontSize: subtitleSize * 0.9,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
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
                                ],
                              ),
                              Divider(height: spacing),
                              
                              // Location
                              Text(
                                'Location/City *',
                                style: TextStyle(
                                  fontSize: labelSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: smallSpacing * 0.5),
                              TextFormField(
                                controller: _locationController,
                                decoration: inputDecoration.copyWith(
                                  hintText: 'Enter the city or area',
                                  prefixIcon: Icon(Icons.location_on, size: iconSize * 0.8),
                                ),
                                style: TextStyle(fontSize: labelSize),
                                validator: Validators.required('Location is required'),
                                enabled: !_useCurrentLocation,
                              ),
                              SizedBox(height: spacing * 0.75),
                              
                              // Region
                              Text(
                                'Region/State',
                                style: TextStyle(
                                  fontSize: labelSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: smallSpacing * 0.5),
                              TextFormField(
                                controller: _regionController,
                                decoration: inputDecoration.copyWith(
                                  hintText: 'Enter the region or state',
                                  prefixIcon: Icon(Icons.map, size: iconSize * 0.8),
                                ),
                                style: TextStyle(fontSize: labelSize),
                                enabled: !_useCurrentLocation,
                              ),
                              SizedBox(height: spacing * 0.75),
                              
                              // Country
                              Text(
                                'Country *',
                                style: TextStyle(
                                  fontSize: labelSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: smallSpacing * 0.5),
                              TextFormField(
                                controller: _countryController,
                                decoration: inputDecoration.copyWith(
                                  hintText: 'Enter the country',
                                  prefixIcon: Icon(Icons.flag, size: iconSize * 0.8),
                                ),
                                style: TextStyle(fontSize: labelSize),
                                validator: Validators.required('Country is required'),
                                enabled: !_useCurrentLocation,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      
                      // Additional Information
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Additional Information',
                                style: TextStyle(
                                  fontSize: subtitleSize * 1.1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(height: spacing),
                              
                              // Contact Information
                              Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: labelSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: smallSpacing * 0.5),
                              TextFormField(
                                controller: _contactController,
                                decoration: inputDecoration.copyWith(
                                  hintText: 'Phone number, email, etc.',
                                  prefixIcon: Icon(Icons.contact_phone, size: iconSize * 0.8),
                                ),
                                style: TextStyle(fontSize: labelSize),
                              ),
                              SizedBox(height: spacing * 0.75),
                              
                              // Description
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: labelSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: smallSpacing * 0.5),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: inputDecoration.copyWith(
                                  hintText: 'Additional details about the market',
                                  prefixIcon: Icon(Icons.description, size: iconSize * 0.8),
                                  alignLabelWithHint: true,
                                ),
                                style: TextStyle(fontSize: labelSize),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 1.5),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Add Market',
                            style: TextStyle(
                              fontSize: buttonTextSize,
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
    );
  }
}

