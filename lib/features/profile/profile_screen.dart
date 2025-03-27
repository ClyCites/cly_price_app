import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import '../settings/settings_screen.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    
    if (!userProvider.isLoggedIn) {
      return _buildLoginPrompt(context);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(user: userProvider.user!),
            SizedBox(height: 16),
            SettingsSection(
              title: 'Settings',
              items: [
                // Add your settings items here
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Please log in to view your profile',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showLoginDialog(context),
              child: Text('Log In'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log In'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
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
                          final success = await authProvider.login(
                            emailController.text,
                            passwordController.text,
                          );
                          if (success) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(userProvider.error ?? 'Login failed'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: userProvider.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Log In'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

