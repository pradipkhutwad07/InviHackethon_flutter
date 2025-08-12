// lib/screens/login_screen.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shelflife/services/api_service.dart';
import 'package:shelflife/services/auth_service.dart';
import 'package:shelflife/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isDevMode = true; // Default to development mode

  late ApiService _apiService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authService = AuthService();
    _apiService.setBaseUrl(ApiService.devBaseUrl); // default
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final fcmToken = await getFcmToken() ?? 'default_token';

        await _apiService.setBaseUrl(
          _isDevMode ? ApiService.devBaseUrl : ApiService.prodBaseUrl,
        );

        final response = await _apiService.post('login', {
          'email': _emailController.text,
          'password': _passwordController.text,
          'fcmToken': fcmToken,
        });

        print('Login response: $response');

        if (response != null && response['status'] == 1) {
          // Extract the access token from response['data']
          final token = response['data']?['access_token'];
          if (token != null) {
            await _authService.saveToken(token);

            // Navigate to dashboard screen using Navigator
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            setState(() {
              _errorMessage = 'Login failed: Token missing.';
            });
          }
        } else {
          setState(() {
            _errorMessage =
                response?['message'] ?? 'Login failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> getFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');
      return fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Environment Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Development'),
                  Switch(
                    value: _isDevMode,
                    onChanged: (value) async {
                      setState(() {
                        _isDevMode = value;
                      });
                      await _apiService.setBaseUrl(
                        value ? ApiService.devBaseUrl : ApiService.prodBaseUrl,
                      );
                    },
                  ),
                  const Text('Production'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Current Environment: ${_isDevMode ? "Development" : "Production"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(onPressed: _login, child: const Text('Login')),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Don\'t have an account? Click here to register',
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
