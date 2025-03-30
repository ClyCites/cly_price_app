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
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.06; // Responsive padding
    final spacer = size.height * 0.02; // Responsive spacing
    final titleSize = size.width * 0.06; // Responsive title size
    final subtitleSize = size.width * 0.035; // Responsive subtitle size
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
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
                      child: _emailSent 
                        ? _buildSuccessView(titleSize, subtitleSize, spacer) 
                        : _buildFormView(authProvider, titleSize, subtitleSize, spacer),
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

  Widget _buildFormView(AuthProvider authProvider, double titleSize, double subtitleSize, double spacer) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacer * 0.5),
          Text(
            'Enter your email address and we\'ll send you instructions to reset your password',
            style: TextStyle(
              fontSize: subtitleSize,
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
          SizedBox(height: spacer * 2),
          
          // Reset Button
          AuthButton(
            text: 'Send Reset Link',
            isLoading: authProvider.isLoading,
            onPressed: _resetPassword,
          ),
          SizedBox(height: spacer * 1.5),
          
          // Back to Login
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSuccessView(double titleSize, double subtitleSize, double spacer) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.2; // Responsive icon size
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: iconSize,
        ),
        SizedBox(height: spacer * 1.5),
        Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacer),
        Text(
          'We\'ve sent password reset instructions to:',
          style: TextStyle(
            fontSize: subtitleSize,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacer * 0.5),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: subtitleSize * 1.1,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacer * 1.5),
        Text(
          'Please check your email and follow the instructions to reset your password.',
          style: TextStyle(
            fontSize: subtitleSize,
            color: AppColors.textMedium,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacer * 2),
        AuthButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        
        const Spacer(),
      ],
    );
  }
}

