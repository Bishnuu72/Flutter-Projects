import 'package:flutter/material.dart';
import 'package:manshi/screens/login_screen.dart';
import 'package:manshi/screens/register_screen.dart';

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness App',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        'login_screen': (context) => const LoginScreen(),
        'register_screen': (context) => const RegisterScreen(),
      }
    );
  }
}
