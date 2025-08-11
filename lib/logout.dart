// logout.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login.dart';

class LogoutScreen extends StatefulWidget {
  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
    _handleLogout();
  }

  Future<void> _handleLogout() async {
    final result = await ApiService.logout();
    if (result['success'] == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Logout failed')),
      );
      Navigator.pop(context); // Go back if logout failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
