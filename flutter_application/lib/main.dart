import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(VestrAIApp());
}

class VestrAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VestrAI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}