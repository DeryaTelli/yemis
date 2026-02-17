import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Define the color scheme based heavily on the primary orange color
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        // You can customize secondary, tertiary, etc. if needed
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white, // Text color on valid
        centerTitle: true,
      ),

      // Text Theme - Apply Google Fonts globally
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: AppColors.primaryTextColor,
        displayColor: AppColors.primaryTextColor,
      ),

      // Input Decoration Theme (for TextFields)
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.hintTextColor),
        // Add more default styling like borders if desired
      ),

      // Button Theme (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor, // Default background
          foregroundColor: Colors.white, // Default text color
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: AppColors.unselectedButtonTextColor, // "5. Seçilmemiş buton yazısı"
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold), // Default button text style
        ),
      ),
    );
  }
}
