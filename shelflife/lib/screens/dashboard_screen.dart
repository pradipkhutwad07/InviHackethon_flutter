// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:shelflife/services/api_service.dart';
import 'package:shelflife/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'User';
  String _currentEnvironment = '';
  late AuthService _authService;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService();
    _apiService = ApiService(); // Assuming ApiService takes AuthService

    await _fetchDashboardData();
    await _fetchEnvironment();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await _apiService.get('user'); // Replace with actual endpoint
      if (response != null && response['name'] != null) {
        setState(() {
          _userName = response['name'];
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      if (e.toString().contains('Unauthorized')) {
        // Handle unauthorized case, e.g., navigate to login
      }
    }
  }

  Future<void> _fetchEnvironment() async {
    final baseUrl = _apiService.getBaseUrl();
    setState(() {
      _currentEnvironment =
           'Development';
    });
  }

  Future<void> _logout() async {
    await _authService.removeToken();
    // Navigate to login screen after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $_userName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text('Current Environment: $_currentEnvironment'),
            const SizedBox(height: 20),
            const Text('This is your dashboard.'),
          ],
        ),
      ),
    );
  }
}
