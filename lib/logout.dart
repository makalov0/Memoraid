import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login.dart';
import 'widgets/app_background.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});
  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
    _handleLogout();
  }

  Future<void> _handleLogout() async {
    final result = await ApiService.logout();
    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Logout failed')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA9BCCF),
      body: Stack(
        children: const [
          AppBackground(topGap: 0, child: SizedBox.shrink()),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
