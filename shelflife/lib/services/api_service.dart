// lib/services/api_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService;
  static const String _baseUrlKey = 'baseUrl';
  static const String devBaseUrl =
      'https://70c0cda8a035.ngrok-free.app'; // Development URL (Android emulator)
  static const String prodBaseUrl =
      'https://70c0cda8a035.ngrok-free.app'; // Production URL

  ApiService({AuthService? authService})
    : _authService = authService ?? AuthService();

  // Get the current base URL
  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? devBaseUrl; // Default to dev
  }

  // Set the base URL
  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  // Toggle between dev and prod
  Future<void> toggleBaseUrl() async {
    final currentUrl = await getBaseUrl();
    await setBaseUrl(currentUrl == devBaseUrl ? prodBaseUrl : devBaseUrl);
  }

  // Get headers with optional Bearer token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Generic GET
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${await getBaseUrl()}/$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${await getBaseUrl()}/$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${await getBaseUrl()}/$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic DELETE
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${await getBaseUrl()}/$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Response handler
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'status': 1, 'data': jsonDecode(response.body)};
    } else {
      return {'status': 0, 'error': response.body, 'code': response.statusCode};
    }
  }
}
