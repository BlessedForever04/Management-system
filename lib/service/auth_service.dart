import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:managementt/config.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/model/auth_response.dart';

class AuthService {
  // Login and logout intentionally use raw http — NOT ApiService.
  // ApiService attaches "Authorization: Bearer <token>" to every request.
  // At login time there is no token yet, so using ApiService would send
  // "Bearer " (empty), the backend returns 401, and the refresh flow
  // immediately throws "Session expired" before login completes.

  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('${response.statusCode}: ${response.body}');
    }
  }

  /// Register a new user (called when admin adds an employee).
  Future<void> register(String username, String password, String role) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );
    if (response.statusCode != 200) {
      final message = response.body.isNotEmpty
          ? response.body.replaceAll('"', '')
          : 'Registration failed';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      final auth = AuthController.to;
      await http.post(
        Uri.parse('${Config.baseUrl}/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': auth.refreshToken.value}),
      );
    } catch (_) {
      // Best-effort — still clear local session even if backend call fails.
    }
  }
}
