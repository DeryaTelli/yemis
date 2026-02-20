import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'text_styles_custom.dart';

/// Uygulama bölümlerini temsil eder.
enum AppSection {
  /// İşletme ve yemek bölümleri (turuncu tema)
  food,

  /// Gönüllülük bölümü (yeşil tema)
  volunteer,
}

class AppTheme {

  AppTheme._();

  // ---------------------------------------------------------------------------
  // İşletme & Yemek — Turuncu Tema (#FE8800)
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme => _buildTheme(
        primaryColor: AppColors.primaryColor,
      );

  // ---------------------------------------------------------------------------
  // Gönüllülük — Yeşil Tema (#22B05A)
  // ---------------------------------------------------------------------------
  static ThemeData get volunteerTheme => _buildTheme(
        primaryColor: AppColors.volunteerColor,
      );

  // ---------------------------------------------------------------------------
  // Bölüme göre tema seç
  // ---------------------------------------------------------------------------
  static ThemeData themeFor(AppSection section) {
    switch (section) {
      case AppSection.volunteer:
        return volunteerTheme;
      case AppSection.food:
        return lightTheme;
    }
  }

  // ---------------------------------------------------------------------------
  // Ortak tema fabrikası
  // ---------------------------------------------------------------------------
  static ThemeData _buildTheme({required Color primaryColor}) {
    return ThemeData(
      useMaterial3: true,

      // Renk şeması
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
      ),

      // AppBar teması
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: CustomTextStyles.orelegaOne32White,
      ),

      // Metin teması
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: AppColors.primaryTextColor,
        displayColor: AppColors.primaryTextColor,
      ),

      // TextField teması
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.hintTextColor),
      ),

      // Buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: AppColors.unselectedButtonTextColor,
          textStyle:
              GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
