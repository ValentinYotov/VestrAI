import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_form_screen.dart';
import 'screens/login_form_screen.dart';
import 'screens/news_screen.dart';
// Добавен за използване (по избор)

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VestrAI',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1C2526),
        scaffoldBackgroundColor: const Color(0xFF1C2526),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F3A44),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0B90B),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignUpFormScreen(),
  '/home': (context) => HomeScreen(),
  '/login_form': (context) => const LoginFormScreen(),
  '/news': (context) => const NewsScreen(),
},
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => LoginScreen());
      },
    );
  }
}