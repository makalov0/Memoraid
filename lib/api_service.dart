// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// Android emulator http://10.0.2.2/app-backend
  static const String baseUrl = 'http://localhost/app-backend';

  // -------------------- AUTH: REGISTER --------------------

  static Future<Map<String, dynamic>> register({
    String? username,
    String? email,
    String? usernameOrEmail,
    required String password,
  }) async {
    try {
      final body = <String, String>{'register': '1', 'password': password};

      if (usernameOrEmail != null && (username == null && email == null)) {
        if (_looksLikeEmail(usernameOrEmail)) {
          
          final name = usernameOrEmail.split('@').first;
          body['username'] = name.isEmpty ? 'user' : name;
          body['email'] = usernameOrEmail;
        } else {
          
          body['username'] = usernameOrEmail;
          body['email'] = ''; 
        }
      } else if (username != null && email != null) {
        body['username'] = username;
        body['email'] = email;
      } else {
        return {
          'success': false,
          'message':
              'Provide either (username + email) or (usernameOrEmail).'
        };
      }

      final res = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      final data = _decodeJson(res.body);
      if (res.statusCode == 200 && _asBool(data['success']) == true) {
        if (data['user'] is Map<String, dynamic>) {
          await _saveUserSession(data['user'] as Map<String, dynamic>);
        }
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Register failed (${res.statusCode})'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // -------------------- AUTH: LOGIN --------------------

  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'login': '1',
          'username_or_email': usernameOrEmail,
          'password': password,
        },
      );

      final data = _decodeJson(res.body);
      if (res.statusCode == 200 && _asBool(data['success']) == true) {
        if (data['user'] is Map<String, dynamic>) {
          await _saveUserSession(data['user'] as Map<String, dynamic>);
        }
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Login failed (${res.statusCode})'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // -------------------- AUTH: LOGOUT --------------------

  static Future<Map<String, dynamic>> logout() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/logout.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      final data = _decodeJson(res.body);
    
      await clearUserSession();

      if (res.statusCode == 200) return data;
      return {
        'success': false,
        'message': data['message'] ?? 'Logout failed (${res.statusCode})'
      };
    } catch (e) {
      await clearUserSession();
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // -------------------- SESSION (SharedPreferences) --------------------

  static Future<void> _saveUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    
    final userId =
        (user['id'] ?? user['user_id'] ?? 0).toString(); 
    final username = (user['username'] ?? user['name'] ?? '').toString();
    final email = (user['email'] ?? '').toString();

    await prefs.setString('user_id', userId);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<Map<String, dynamic>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool('isLoggedIn') ?? false,
      'user_id': prefs.getString('user_id') ?? '0',
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
    };
  }

  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
  }

  // -------------------- HELPERS --------------------

  static bool _looksLikeEmail(String s) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);

  static Map<String, dynamic> _decodeJson(String raw) {
    try {
      final j = json.decode(raw);
      return (j is Map<String, dynamic>) ? j : <String, dynamic>{'raw': j};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

 
  static bool? _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return null;
    }
}
