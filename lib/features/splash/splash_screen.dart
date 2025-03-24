import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    
    Timer(const Duration(seconds: 3), () {
      checkAuthAndNavigate();
    });
  }

  void checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
    
    if (mounted) {
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen())
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen())
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo and App Name
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 800)),
                  ScaleEffect(duration: Duration(milliseconds: 800)),
                ],
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(75),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.agriculture,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 400),
                  ),
                ],
                child: Text(
                  'ClyCites',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 600),
                  ),
                ],
                child: Text(
                  'Agricultural Price Intelligence',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Loading indicator
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 800),
                    delay: Duration(milliseconds: 800),
                  ),
                ],
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

