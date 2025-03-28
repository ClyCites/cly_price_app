import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../features/common/widgets/app_button.dart';
import '../../features/common/widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _profileImage;
  String? _base64Image;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.user?.name ?? '');
    _emailController = TextEditingController(text: authProvider.user?.email ?? '');
    
    // Load user profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.getUserProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      
      // Convert image to base64
      final bytes = await _profileImage!.readAsBytes();
      _base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profilePicture: _base64Image,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _isEditing = false;
          _profileImage = null;
          _base64Image = null;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: authProvider.isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.lightGrey,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (user?.profilePicture != null
                                    ? NetworkImage(user!.profilePicture!)
                                    : null) as ImageProvider?,
                            child: (user?.profilePicture == null && _profileImage == null)
                                ? const Icon(Icons.person, size: 60, color: AppColors.textMedium)
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // User Info
                    if (_isEditing) ...[
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.required('Name is required'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Validators.email('Please enter a valid email'),
                      ),
                      const SizedBox(height: 32),
                      
                      // Save Button
                      AppButton(
                        text: 'Save Changes',
                        isLoading: authProvider.isLoading,
                        onPressed: _saveProfile,
                      ),
                      const SizedBox(height: 16),
                      
                      // Cancel Button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = user?.name ?? '';
                            _emailController.text = user?.email ?? '';
                            _profileImage = null;
                            _base64Image = null;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    ] else ...[
                      // Display Name
                      Text(
                        user?.name ?? 'No Name',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Display Email
                      Text(
                        user?.email ?? 'No Email',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Display Role
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user?.role?.toUpperCase() ?? 'USER',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Account Info Section
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Account Settings
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Account Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to account settings
                        },
                      ),
                      
                      // Notifications
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text('Notifications'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to notifications settings
                        },
                      ),
                      
                      // Privacy & Security
                      ListTile(
                        leading: const Icon(Icons.security_outlined),
                        title: const Text('Privacy & Security'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to privacy settings
                        },
                      ),
                      
                      // Help & Support
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to help & support
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Logout Button
                      AppButton(
                        text: 'Logout',
                        isLoading: authProvider.isLoading,
                        type: AppButtonType.danger,
                        onPressed: () async {
                          await authProvider.signOut();
                          if (mounted) {
                            Navigator.of(context).pushReplacementNamed('/login');
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

