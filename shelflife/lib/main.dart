import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import 'services/api_service.dart';
import 'services/auth_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/registration_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize AuthService
  final authService = AuthService();

  // Initialize ApiService
  final apiService = ApiService();

  runApp(
    MyApp(
      authService: authService,
      apiService: apiService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ApiService apiService;

  const MyApp({super.key, required this.authService, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShelfLife',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define Lottie animation colors to match the theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(apiService: apiService,authService: authService),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
