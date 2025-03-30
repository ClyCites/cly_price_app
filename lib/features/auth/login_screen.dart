import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
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
            content: Text(authProvider.error ?? 'Login failed'),
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
    
    return Scaffold(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: spacer * 2),
                        
                        // Logo and App Name
                        Animate(
                          effects: const [
                            FadeEffect(duration: Duration(milliseconds: 600)),
                            SlideEffect(
                              begin: Offset(0, -0.2),
                              end: Offset.zero,
                              duration: Duration(milliseconds: 600),
                            ),
                          ],
                          child: Column(
                            children: [
                              Container(
                                width: size.width * 0.2,
                                height: size.width * 0.2,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.agriculture,
                                  size: size.width * 0.1,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: spacer),
                              Text(
                                'ClyCites',
                                style: TextStyle(
                                  fontSize: size.width * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: spacer * 0.5),
                              Text(
                                'Agricultural Price Intelligence',
                                style: TextStyle(
                                  fontSize: size.width * 0.035,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: spacer * 3),
                        
                        // Login Form
                        Expanded(
                          child: Animate(
                            effects: const [
                              FadeEffect(
                                duration: Duration(milliseconds: 600),
                                delay: Duration(milliseconds: 300),
                              ),
                              SlideEffect(
                                begin: Offset(0, 0.2),
                                end: Offset.zero,
                                duration: Duration(milliseconds: 600),
                                delay: Duration(milliseconds: 300),
                              ),
                            ],
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: size.width * 0.06,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: spacer * 0.5),
                                  Text(
                                    'Welcome back! Please login to your account',
                                    style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                  SizedBox(height: spacer * 1.5),
                                  
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
                                    hintText: 'Enter your password',
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
                                    validator: Validators.required('Password is required'),
                                  ),
                                  SizedBox(height: spacer * 0.5),
                                  
                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                        );
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
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontSize: size.width * 0.035,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacer * 1.5),
                                  
                                  // Login Button
                                  AuthButton(
                                    text: 'Login',
                                    isLoading: authProvider.isLoading,
                                    onPressed: _login,
                                  ),
                                  
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Register Link
                        Animate(
                          effects: const [
                            FadeEffect(
                              duration: Duration(milliseconds: 600),
                              delay: Duration(milliseconds: 600),
                            ),
                          ],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: size.width * 0.035,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  );
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
                                  'Register',
                                  style: TextStyle(
                                    fontSize: size.width * 0.035,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacer),
                      ],
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

