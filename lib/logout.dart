// logout_dialog.dart - Create this as a separate file or add to your existing file
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login.dart';

class LogoutHelper {
  // Main function to show logout confirmation dialog
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.exit_to_app,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1E3A5F), // Match your app theme
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                size: 48,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'Do you want to logout?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            // No Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Just close dialog
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8),
            // Yes Button
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                await _performLogout(context); // Then perform logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to perform the actual logout
  static Future<void> _performLogout(BuildContext context) async {
    // Show loading dialog while logging out
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF1E3A5F), // Match your app theme
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Logging out...',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final result = await ApiService.logout();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Logged out successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Navigate to login screen and clear all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text(result['message'] ?? 'Logout failed')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Network error: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

// Example: How to use in your app (replace your current logout button/menu item)
class ExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memoraid'),
        backgroundColor: Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        actions: [
          // Logout button in AppBar
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => LogoutHelper.showLogoutDialog(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E3A5F),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // Logout option in drawer
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Logout'),
              subtitle: Text('Sign out of your account'),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                LogoutHelper.showLogoutDialog(context); // Then show dialog
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Example logout button
            ElevatedButton.icon(
              onPressed: () => LogoutHelper.showLogoutDialog(context),
              icon: Icon(Icons.exit_to_app),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}