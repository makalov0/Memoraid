import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
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

  // Get categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_categories.php'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get study cards for a category
  static Future<Map<String, dynamic>> getStudyCards(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_study_cards.php?category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save user progress for a card
  static Future<Map<String, dynamic>> saveCardProgress({
    required int userId,
    required int cardId,
    required bool remembered,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_progress.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': userId.toString(),
          'card_id': cardId.toString(),
          'remembered': remembered.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save study session results
  static Future<Map<String, dynamic>> saveStudySession({
    required int userId,
    required int categoryId,
    required int totalCards,
    required int rememberedCount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_session.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': userId.toString(),
          'category_id': categoryId.toString(),
          'total_cards': totalCards.toString(),
          'remembered_count': rememberedCount.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_user_stats.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get category by name (for existing games)
  static Future<Map<String, dynamic>> getCategoryByName(String categoryName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_category_by_name.php?category_name=${Uri.encodeComponent(categoryName)}'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Google Sign-In
  static Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google_login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id_token': idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await _saveUserSession(data['user']);
        }
        return data;
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'logout': '1',
        },
      );

      // Always clear local session
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': true, 'message': 'Logged out locally'};
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return {'success': true, 'message': 'Logged out locally'};
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
}