import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Warna Utama (Sesuai Referensi UI Halal Financial)
  static const Color primaryDark = Color(0xFF0D47A1); 
  static const Color primary = Color(0xFF1E88E5); 
  static const Color primaryLight = Color(0xFF00BCD4); 
  
  static const Color background = Color(0xFFF4F7FC);
  static const Color cardColor = Colors.white;
  
  static const Color success = Color(0xFF00BFA5); 
  static const Color danger = Color(0xFFFF5252); 
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
    );
  }
}