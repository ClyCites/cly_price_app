import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
// import '../../../core/theme/app_colors.dart';
import '../../../features/common/widgets/app_button.dart';
// import '../../../features/common/widgets/loading_indicator.dart';

class ProfileHeader extends StatefulWidget {
  final User user;
  final bool isEditable;

  const ProfileHeader({
    Key? key, 
    required this.user,
    this.isEditable = true,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  Future<String?> _getBase64Image() async {
    if (_imageFile == null) return null;
    
    try {
      final bytes = await _imageFile!.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
      return null;
    }
  }
  
  void _toggleEditMode() {
    setState(() {
      if (!_isEditing) {
        // Entering edit mode - initialize controllers with current values
        _nameController.text = widget.user.name ?? '';
        _emailController.text = widget.user.email ?? '';
      }
      _isEditing = !_isEditing;
      _imageFile = null; // Reset image file when toggling
    });
  }
  
  Future<void> _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Convert image to base64 if selected
    String? base64Image;
    if (_imageFile != null) {
      base64Image = await _getBase64Image();
    }
    
    final success = await userProvider.updateUserProfile(
      name: _nameController.text,
      email: _emailController.text,
      profilePicture: base64Image,
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: _isEditing ? _buildEditMode() : _buildViewMode(),
    );
  }
  
  Widget _buildViewMode() {
    return Column(
      children: [
        // Profile Picture
        Hero(
          tag: 'profile_picture_${widget.user.id}',
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: widget.user.profilePicture != null && widget.user.profilePicture!.isNotEmpty
                ? NetworkImage(widget.user.profilePicture!) as ImageProvider<Object>
                : null,
            child: widget.user.profilePicture == null || widget.user.profilePicture!.isEmpty
                ? Text(
                    (widget.user.name?.isNotEmpty == true 
                      ? widget.user.name!.substring(0, 1).toUpperCase() 
                      : '?'),
                    style: TextStyle(
                      fontSize: 36,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        
        // User Name
        Text(
          widget.user.name ?? 'Unknown',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        
        // User Email
        Text(
          widget.user.email ?? 'No email provided',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        
        // User Role
        Chip(
          label: Text(
            (widget.user.role?.toUpperCase() ?? 'USER'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        const SizedBox(height: 16),
        
        // Action Buttons
        if (widget.isEditable) ...[
          AppButton(
            text: 'Edit Profile',
            icon: Icons.edit,
            type: AppButtonType.outline,
            onPressed: _toggleEditMode,
          ),
          const SizedBox(height: 8),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return AppButton(
                text: 'Log Out',
                icon: Icons.logout,
                type: AppButtonType.danger,
                size: AppButtonSize.small,

                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        AppButton(
                          text: 'Log Out',
                          type: AppButtonType.danger,
                          size: AppButtonSize.small,
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true && context.mounted) {
                    await authProvider.signOut();
                    // Navigate to login screen
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              );
            },
          ),
        ],
      ],
    );
  }
  
  Widget _buildEditMode() {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Column(
      children: [
        // Profile Picture with Edit Option
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: widget.user.profilePicture != null && widget.user.profilePicture!.isNotEmpty
                ? NetworkImage(widget.user.profilePicture!) as ImageProvider<Object>
                : null,
                child: (_imageFile == null && (widget.user.profilePicture == null || widget.user.profilePicture!.isEmpty))
                    ? Text(
                        (widget.user.name?.isNotEmpty == true 
                          ? widget.user.name!.substring(0, 1).toUpperCase() 
                          : '?'),
                        style: TextStyle(
                          fontSize: 36,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Name Field
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        
        // Email Field
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Cancel',
                type: AppButtonType.outline,
                onPressed: _toggleEditMode,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: 'Save',
                type: AppButtonType.primary,
                isLoading: userProvider.isLoading,
                onPressed: _saveProfile,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
