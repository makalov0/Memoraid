import 'package:flutter/material.dart';
import 'register.dart';
import 'index.dart';
import 'api_service.dart';
import 'widgets/app_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  static const Color steel = Color(0xFFA9BCCF);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final s = await ApiService.getUserSession();
    if (!mounted) return;
    if (s['isLoggedIn'] == true) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => IndexScreen()));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final res = await ApiService.login(
      usernameOrEmail: _usernameController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Welcome back!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => IndexScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(res['message'] ?? 'Login failed'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _toRegister() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _social(String p) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('$p login not implemented yet'),
          backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final scale = (h / 800).clamp(0.70, 1.00);
    double s(double v) => v * scale;
    final pillR = s(22.0);

    return Scaffold(
      backgroundColor: steel,
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        topGap: s(150), // ลดลงให้มีพื้นที่โลโก้ด้านบน
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----- Logo Text -----
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Memoraid',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: s(32),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: s(50)),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EDF3),
                  borderRadius: BorderRadius.circular(pillR),
                ),
                padding: EdgeInsets.all(s(4)),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: s(40),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(pillR),
                        ),
                        child: Text('Log In',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: s(14))),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: _toRegister,
                        borderRadius: BorderRadius.circular(pillR),
                        child: SizedBox(
                          height: s(40),
                          child: Center(
                            child: Text('Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: s(14),
                                  color: Colors.blueGrey,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: s(16)),

              // Inputs
              _pillField(
                controller: _usernameController,
                hint: 'Username or Email',
                radius: pillR,
                vPad: s(14),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your username or email';
                  }
                  final t = v.trim();
                  final isEmail =
                      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(t);
                  final isUser = t.length >= 3 && !t.contains(' ');
                  return (!isEmail && !isUser)
                      ? 'Enter a valid username or email'
                      : null;
                },
              ),
              SizedBox(height: s(12)),
              _pillField(
                controller: _passwordController,
                hint: 'Password',
                radius: pillR,
                vPad: s(14),
                obscure: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter your password' : null,
              ),
              SizedBox(height: s(16)),

              // Button
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: s(110),
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1989FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: s(10)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(pillR),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Log In',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: s(14))),
                  ),
                ),
              ),
              SizedBox(height: s(8)),

              Align(
                alignment: Alignment.center,
                child: Text('or',
                    style:
                        TextStyle(color: Colors.black54, fontSize: s(14))),
              ),
              SizedBox(height: s(8)),

              // Socials
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialCircle(
                      size: s(46),
                      child: const Icon(Icons.close, color: Colors.white),
                      bg: Colors.black,
                      onTap: () => _social('X')),
                  SizedBox(width: s(18)),
                  _socialCircle(
                      size: s(46),
                      child: const Icon(Icons.facebook, color: Colors.white),
                      bg: const Color(0xFF1877F2),
                      onTap: () => _social('Facebook')),
                  SizedBox(width: s(18)),
                  _socialCircle(
                    size: s(46),
                    child: Text('G',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: s(18),
                            color: Colors.red)),
                    bg: Colors.white,
                    border: Colors.grey.shade300,
                    onTap: () => _social('Google'),
                  ),
                ],
              ),
              SizedBox(height: s(8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillField({
    required TextEditingController controller,
    required String hint,
    required double radius,
    double vPad = 14,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 18, vertical: vPad),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialCircle({
    required double size,
    required Widget child,
    required Color bg,
    Color? border,
    VoidCallback? onTap,
  }) {
    return InkResponse(
      onTap: onTap,
      radius: size / 2 + 6,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border != null ? Border.all(color: border) : null,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
