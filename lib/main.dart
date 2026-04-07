import 'package:flutter/material.dart';
import 'package:gestabsence/screens/login_screen.dart';
import 'package:gestabsence/themeapp.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _activeScreen;

  void _openScreen(Widget screen) {
    setState(() {
      _activeScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gest Absence',
      theme: appTheme(),
      home: _activeScreen ?? LoginScreen(onLoginSuccess: _openScreen),
    );
  }
}
