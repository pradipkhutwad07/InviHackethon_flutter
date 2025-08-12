import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shelflife/services/api_service.dart';
import 'package:shelflife/services/auth_service.dart';
import 'package:shelflife/screens/login_screen.dart';
import 'package:shelflife/screens/dashboard_screen.dart'; // Import your dashboard screen

class SplashScreen extends StatefulWidget {
  final ApiService apiService;
  final AuthService authService;

  const SplashScreen({super.key, required this.apiService, required this.authService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // Keep splash delay

    if (!mounted) return;

    // Check token existence
    bool hasToken = await widget.authService.hasToken();

    if (hasToken) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/Timer.json',
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
