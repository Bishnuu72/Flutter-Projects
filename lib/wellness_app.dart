import 'package:flutter/material.dart';
import 'package:manshi/screens/login_screen.dart';

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness App',
      home: MyLogin(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
    );
  }
}
