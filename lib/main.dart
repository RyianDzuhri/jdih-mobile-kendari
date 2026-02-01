import 'package:flutter/material.dart';
import 'ui/home/home_screen.dart'; // Arahkan ke file yang baru dibuat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JDIH Kendari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1a237e)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}