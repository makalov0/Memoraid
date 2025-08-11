// api_service.dart - Create this new file
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Replace with your actual server URL
  static const String baseUrl = 'http://localhost/app-backend';
  // For Android emulator use: 'http://10.0.2.2/app-backend'
  
  // Register user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'register': '1',
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Save user session locally
          await _saveUserSession(data['user']);
        }
        return data;
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'login': '1',
          'username_or_email': usernameOrEmail,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Save user session locally
          await _saveUserSession(data['user']);
        }
        return data;
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save user session locally
  static Future<void> _saveUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('username', user['username']);
    await prefs.setString('email', user['email']);
    await prefs.setBool('isLoggedIn', true);
  }

  // Get user session
  static Future<Map<String, dynamic>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool('isLoggedIn') ?? false,
      'user_id': prefs.getInt('user_id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
    };
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Clear local session
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        return data;
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}