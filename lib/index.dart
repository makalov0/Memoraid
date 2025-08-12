import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login.dart';
import 'flashcard.dart'; // Import the original flashcard game
import 'quizlet_flashcard.dart'; // Import the new Quizlet-style game

class IndexScreen extends StatefulWidget {
  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  final List<CategoryItem> categories = [
    CategoryItem(
      icon: Icons.flight_takeoff,
      label: 'Travel',
      color: Colors.blue[100]!,
    ),
    CategoryItem(
      icon: Icons.pets,
      label: 'Animal',
      color: Colors.green[100]!,
    ),
    CategoryItem(
      icon: Icons.work_outline,
      label: 'Job',
      color: Colors.orange[100]!,
    ),
    CategoryItem(
      icon: Icons.calculate_outlined,
      label: 'CRC',
      color: Colors.purple[100]!,
    ),
    CategoryItem(
      icon: Icons.menu_book,
      label: 'Read',
      color: Colors.teal[100]!,
    ),
    CategoryItem(
      icon: Icons.restaurant,
      label: 'Food',
      color: Colors.red[100]!,
    ),
  ];

  // User data - only fields from your database
  Map<String, dynamic> userData = {
    'id': '12345',
    'username': 'JohnDoe',
    'email': 'johndoe@example.com',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load real user data from SharedPreferences
  }

  // Function to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userData['id'] = prefs.getString('user_id') ?? '12345';
        userData['username'] = prefs.getString('username') ?? 'JohnDoe';
        userData['email'] = prefs.getString('user_email') ?? 'johndoe@example.com';
      });
    } catch (e) {
      print('Error loading user data: $e');
      // Keep default values if loading fails
    }
  }

  // Updated logout function to show confirmation dialog
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  color: Color(0xFF1E3A5F),
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
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
  Future<void> _performLogout() async {
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
                  color: Colors.blue,
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
      
      Navigator.of(context).pop();
      
      if (result['success'] == true) {
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
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } else {
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
      Navigator.of(context).pop();
      
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

  // Function to show game selection dialog
  void _showGameSelectionDialog(CategoryItem category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(category.icon, color: Colors.grey[700], size: 28),
              SizedBox(width: 12),
              Text(
                '${category.label} Games',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose your study mode:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              
              // Quizlet-style game option
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuizletFlashcardGame(
                          category: category.label,
                          categoryColor: category.color,
                          categoryIcon: category.icon,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                    foregroundColor: Colors.grey[800],
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.swipe, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Study Cards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Swipe to remember/forget',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Original quiz game option
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FlashcardGame(
                          category: category.label,
                          categoryColor: category.color,
                          categoryIcon: category.icon,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey[800],
                    side: BorderSide(color: category.color, width: 2),
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.quiz, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Quiz Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Test your knowledge',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Updated function to handle category tap and show game selection
  void _onCategoryTap(CategoryItem category) {
    _showGameSelectionDialog(category);
  }

  // Function to show profile edit dialog
  void _showEditProfileDialog() {
    final usernameController = TextEditingController(text: userData['username']);
    final emailController = TextEditingController(text: userData['email']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save changes to SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', usernameController.text);
                await prefs.setString('user_email', emailController.text);
                
                setState(() {
                  userData['username'] = usernameController.text;
                  userData['email'] = emailController.text;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to start all categories flashcard game
  void _startAllCategoriesGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.games, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'Choose Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select a category to start learning:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ...categories.map((category) => Container(
                margin: EdgeInsets.only(bottom: 8),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _onCategoryTap(category);
                  },
                  icon: Icon(category.icon, size: 20),
                  label: Text('${category.label}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                    foregroundColor: Colors.grey[800],
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F4FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.grey[700]),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.grey[700]),
              onPressed: _showLogoutDialog,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Profile Header
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[400]!,
                    Colors.blue[600]!,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: userData['avatar'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              userData['avatar'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.blue[600],
                          ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData['username'] ?? 'Username',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userData['email'] ?? 'user@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Profile Details
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.badge, color: Colors.blue[600]),
                    title: Text('User ID'),
                    subtitle: Text(userData['id']?.toString() ?? 'Not available'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.green[600]),
                    title: Text('Username'),
                    subtitle: Text(userData['username'] ?? 'Not provided'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.orange[600]),
                    title: Text('Email'),
                    subtitle: Text(userData['email'] ?? 'Not provided'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.purple[600]),
                    title: Text('Edit Profile'),
                    onTap: () {
                      Navigator.of(context).pop(); // Close drawer
                      _showEditProfileDialog();
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.grey[600]),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Settings coming soon!')),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.help, color: Colors.teal[600]),
                    title: Text('Help & Support'),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Help section coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Logout at bottom
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop(); // Close drawer
                  _showLogoutDialog();
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.games_outlined,
                    size: 24,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Learning Games',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () => _onCategoryTap(category),
                    child: Container(
                      decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                          SizedBox(height: 8),
                          Text(
                            category.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Updated instruction text
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tap any category to choose your game mode!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: FloatingActionButton.extended(
                onPressed: _startAllCategoriesGame,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icon(Icons.play_arrow),
                label: Text(
                  'Start Learning',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CategoryItem {
  final IconData icon;
  final String label;
  final Color color;

  CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}