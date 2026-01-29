import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/home_screen.dart'; // Pastikan folder ui sudah dibuat

void main() {
  runApp(const JdihApp());
}

class JdihApp extends StatelessWidget {
  const JdihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JDIH Kota Kendari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Warna Utama: Biru Navy (Khas Pemerintahan)
        primaryColor: const Color(0xFF1a237e),
        // Warna Background: Abu-abu sangat muda (biar konten menonjol)
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        
        // Menggunakan Font Lato dari Google Fonts
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        
        // Style App Bar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a237e),
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}