import 'package:flutter/material.dart';
import 'api_service.dart'; // <-- Add this import
import 'login.dart';

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

  void _logout() async {
    final result = await ApiService.logout();
    if (result['success']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Logout failed')),
      );
    }
  }

  void _onCategoryTap(CategoryItem category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.label} category selected!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F4FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
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
            onPressed: () {
              // Handle menu
            },
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
              onPressed: _logout,
            ),
          ),
        ],
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
                    Icons.category_outlined,
                    size: 24,
                    color: Colors.grey[700],
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Category Game',
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
            Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting new memory game!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icon(Icons.play_arrow),
                label: Text(
                  'Start Game',
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
