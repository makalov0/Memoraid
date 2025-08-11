import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(MemoraidApp());
}

class MemoraidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memoraid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}