import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shelflife/screens/notification_service.dart';
import 'package:shelflife/screens/registration_screen.dart';
import 'package:shelflife/services/api_service.dart';
import 'package:shelflife/services/auth_service.dart';

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
  bool _isDevMode = true;
  bool _obscurePassword = true;
  late ApiService _apiService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authService = AuthService();
    _apiService.setBaseUrl(ApiService.devBaseUrl);
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
        final fcmToken = await NotificationService().getFcmToken() ?? 'default_token';

        await _apiService.setBaseUrl(
          _isDevMode ? ApiService.devBaseUrl : ApiService.prodBaseUrl,
        );

        final response = await _apiService.post('login', {
          'email': _emailController.text,
          'password': _passwordController.text,
          'fcmToken': fcmToken,
        });

        if (response != null && response['status'] == 1) {
          final token = response['data']?['access_token'];
          if (token != null) {
            await _authService.saveToken(token);
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            setState(() {
              _errorMessage = 'Login failed: Token missing.';
            });
          }
        } else {
          setState(() {
            _errorMessage = response?['message'] ?? 'Login failed. Please try again.';
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
      return fcmToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Environment Toggle
                  Text(
                'ShelfLife',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dot.Net', style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 8),
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
                    const SizedBox(width: 8),
                    Text('Python', style: theme.textTheme.bodyMedium),
                  ],
                ),

                const SizedBox(height: 8),

                // Text(
                //   'Current Environment: ${_isDevMode ? "Development" : "Production"}',
                //   style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                // ),

                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
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

                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Login button or loading indicator
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Login', style: TextStyle(fontSize: 16)),
                        ),
                ),

                const SizedBox(height: 12),

                // Register link
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Register here',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
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
      ),
    );
  }
}
