import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/user_provider.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 36,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : null,
          ),
          SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 8),
          Chip(
            label: Text(
              user.role.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          OutlinedButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Edit Profile'),
            onPressed: () => _showEditProfileDialog(context),
          ),
          SizedBox(height: 8),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return TextButton.icon(
                icon: Icon(Icons.logout),
                label: Text('Log Out'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Log Out'),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Log Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    await userProvider.logout();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.image, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Profile Picture'),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        // In a real app, you would implement image picking here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image picking not implemented in this demo'),
                          ),
                        );
                      },
                      child: Text('Change'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return ElevatedButton(
                  onPressed: userProvider.isLoading
                      ? null
                      : () async {
                          final success = await userProvider.updateUserProfile(
                            name: nameController.text,
                            email: emailController.text,
                          );
                          
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Profile updated successfully'
                                    : userProvider.error ?? 'Failed to update profile',
                              ),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        },
                  child: userProvider.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Save'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

