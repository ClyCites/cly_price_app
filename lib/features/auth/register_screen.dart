import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.06; // Responsive padding
    final spacer = size.height * 0.02; // Responsive spacing
    final titleSize = size.width * 0.06; // Responsive title size
    final subtitleSize = size.width * 0.035; // Responsive subtitle size
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: TextStyle(fontSize: size.width * 0.045),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: size.height * 0.07, // Responsive app bar height
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Join ClyCites',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: spacer * 0.5),
                            Text(
                              'Create an account to access agricultural price intelligence',
                              style: TextStyle(
                                fontSize: subtitleSize,
                                color: AppColors.textMedium,
                              ),
                            ),
                            SizedBox(height: spacer * 1.5),
                            
                            // Name Field
                            AuthTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icons.person_outline,
                              validator: Validators.required('Full name is required'),
                            ),
                            SizedBox(height: spacer),
                            
                            // Email Field
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email('Please enter a valid email'),
                            ),
                            SizedBox(height: spacer),
                            
                            // Password Field
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: 'Create a password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textMedium,
                                  size: size.width * 0.05,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: Validators.password(
                                'Password must be at least 6 characters',
                                minLength: 6,
                              ),
                            ),
                            SizedBox(height: spacer),
                            
                            // Confirm Password Field
                            AuthTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hintText: 'Confirm your password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textMedium,
                                  size: size.width * 0.05,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: spacer * 2),
                            
                            // Register Button
                            AuthButton(
                              text: 'Create Account',
                              isLoading: authProvider.isLoading,
                              onPressed: _register,
                            ),
                            SizedBox(height: spacer * 1.5),
                            
                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: subtitleSize,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.02,
                                      vertical: size.height * 0.01,
                                    ),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: subtitleSize,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: spacer),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

