import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FoodScannerApp());
}

class FoodScannerApp extends StatelessWidget {
  const FoodScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MBG Food Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Global Color Palette ────────────────────────────────────────────────────
class AppColors {
  static const Color primary    = Color(0xFF1E3A6E); // navy blue
  static const Color accent     = Color(0xFFE63946); // red accent
  static const Color background = Color(0xFFF6F1E9); // cream
  static const Color card       = Color(0xFFFFFFFF);
  static const Color textDark   = Color(0xFF1A1A2E);
  static const Color textMuted  = Color(0xFF6B7280);
  static const Color safe       = Color(0xFF22C55E);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color danger     = Color(0xFFEF4444);
  static const Color unknown    = Color(0xFF94A3B8);
}
