import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelflife/screens/notification_service.dart';
import 'package:shelflife/screens/setting_screen.dart';

// Services
import 'services/api_service.dart';
import 'services/auth_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/registration_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If using Flutter binding, initialize here
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Initialize SharedPreferences
  await NotificationService().initialize();
  final prefs = await SharedPreferences.getInstance();

  // Initialize AuthService
  final authService = AuthService();

  // Initialize ApiService
  final apiService = ApiService();

  runApp(MyApp(authService: authService, apiService: apiService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ApiService apiService;

  const MyApp({super.key, required this.authService, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShelfLife',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define Lottie animation colors to match the theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      initialRoute: '/',
      routes: {
        '/':
            (context) =>
                SplashScreen(apiService: apiService, authService: authService),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/setting': (context) => const SettingsPage(),
      },
    );
  }
}
