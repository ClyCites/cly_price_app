import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.forgotPassword(
        _emailController.text.trim(),
      );
      
      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to send reset email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 600)),
              SlideEffect(
                begin: Offset(0, 0.1),
                end: Offset.zero,
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: _emailSent ? _buildSuccessView() : _buildFormView(authProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email address and we\'ll send you instructions to reset your password',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 32),
          
          // Email Field
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email('Please enter a valid email'),
          ),
          const SizedBox(height: 32),
          
          // Reset Button
          AuthButton(
            text: 'Send Reset Link',
            isLoading: authProvider.isLoading,
            onPressed: _resetPassword,
          ),
          const SizedBox(height: 24),
          
          // Back to Login
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Back to Login',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 80,
        ),
        const SizedBox(height: 24),
        Text(
          'Email Sent!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent password reset instructions to:',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Please check your email and follow the instructions to reset your password.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMedium,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AuthButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

