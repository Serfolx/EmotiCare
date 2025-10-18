import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() => runApp(const EmotiCareApp());

class EmotiCareApp extends StatelessWidget {
  const EmotiCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmotiCare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF87CEEB),
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF87CEEB),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const SafeArea(
        bottom: true,
        top: true,
        child: HomeScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

