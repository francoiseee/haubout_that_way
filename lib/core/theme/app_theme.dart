import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants
  static const Color primaryRed = Color(0xFF710E1D);
  static const Color primaryYellow = Color(0xFFFFCC02);
  static const Color textWhite = Colors.white;
  static const Color textBlack = Colors.black;
  
  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: primaryRed,
      fontFamily: GoogleFonts.ubuntu().fontFamily,
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: textWhite,
        elevation: 0,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      headlineSmall: GoogleFonts.ubuntu(
        color: primaryYellow,
        fontSize: 37,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.ubuntu(
        color: textWhite,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      titleMedium: GoogleFonts.interTight(
        color: textBlack,
        fontSize: 25,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: textBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: textBlack, width: 2),
        ),
        minimumSize: const Size(150, 50),
        textStyle: GoogleFonts.interTight(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );
  }
}