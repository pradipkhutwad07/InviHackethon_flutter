// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shelflife/services/api_service.dart';
import 'package:shelflife/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final ApiService apiService;

  const SplashScreen({super.key, required this.apiService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    // Check if the widget is still mounted before navigating
    if (mounted) {
      // Use the apiService to check the environment and navigate accordingly
      final String baseUrl = await widget.apiService.getBaseUrl();
      if (baseUrl.contains('production')) {
        // Navigate to login, assuming login screen handles auth check
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        // For development, also navigate to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/Timer.json', // Make sure you have this file in your assets folder
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
