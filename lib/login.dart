import 'package:flutter/material.dart';
import 'register.dart';
import 'index.dart';
import 'api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Add focus nodes for handling Enter key
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final session = await ApiService.getUserSession();
    if (session['isLoggedIn']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => IndexScreen()),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    // Dispose focus nodes
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await ApiService.login(
        usernameOrEmail: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${result['user']['username']}!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IndexScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _handleSocialLogin(String provider) {
    print('Login with $provider');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF87CEEB),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Memoraid',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                        SizedBox(height: 8),
                        Icon(
                          Icons.lightbulb_outline,
                          size: 48,
                          color: Colors.amber,
                        ),
                        SizedBox(height: 32),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Log In',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _navigateToRegister,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      'Sign Up',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32),

                        // Modified Username field with focus and Enter key handling
                        TextFormField(
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          enabled: !_isLoading,
                          textInputAction: TextInputAction.next, // Show "Next" on keyboard
                          onFieldSubmitted: (value) {
                            // Move focus to password field when Enter is pressed
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          decoration: InputDecoration(
                            hintText: 'Username or Email',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username or email';
                            }
                            final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                            final isUsername = value.length >= 3 && !value.contains(' ');
                            if (!isEmail && !isUsername) {
                              return 'Enter a valid username or email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Modified Password field with focus and Enter key handling
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          enabled: !_isLoading,
                          obscureText: true,
                          textInputAction: TextInputAction.done, // Show "Done" on keyboard
                          onFieldSubmitted: (value) {
                            // Trigger login when Enter is pressed on password field
                            if (!_isLoading) {
                              _handleLogin();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 24),

                        Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _handleSocialLogin('X'),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _handleSocialLogin('Facebook'),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1877F2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.facebook,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _handleSocialLogin('Google'),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Center(
                                  child: Text(
                                    'G',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}