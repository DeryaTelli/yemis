import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextStyles {
  CustomTextStyles._();

  // --- Nunito ---

  // Black (0xFF1B1B1B)
  static TextStyle get regular14Black => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF1B1B1B));
   static TextStyle get extraBold16Black => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1B1B1B)); // Unified color

  // Grey (0xFF838383)
  static TextStyle get regular14Grey => GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF838383));
  static TextStyle get italic14Grey => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: const Color(0xFF838383));
  static TextStyle get regular14GreyHeight => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF838383), height: 24 / 14); // ~1.71
  static TextStyle get regular16Grey => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF838383));
  static TextStyle get semiBold16Grey => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF838383));
  static TextStyle get semiBold16GreyCompact => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF838383), height: 22 / 16, letterSpacing: -0.4);

  // Dark Grey (0xFF4F4F4F)
  static TextStyle get semiBold14DarkGrey => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4F4F4F), height: 20 / 14, letterSpacing: -0.24);
  static TextStyle get semiBold15DarkGrey => GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF4F4F4F), height: 20 / 15, letterSpacing: -0.24);
  static TextStyle get regular16DarkGrey => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF4F4F4F));
  static TextStyle get semiBold16DarkGreyDense => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4F4F4F), height: 12 / 16, letterSpacing: -0.2);
  static TextStyle get semiBold16DarkGreyCompact => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4F4F4F), height: 22 / 16, letterSpacing: -0.4);
  static TextStyle get bold16DarkGreyCompact => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF4F4F4F), height: 22 / 16, letterSpacing: -0.4);
  static TextStyle get extraBold16DarkGrey => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF4F4F4F)); // Unified color
  static TextStyle get extraBold16DarkGreyCompact => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF4F4F4F), height: 22 / 16, letterSpacing: -0.4);
  static TextStyle get extraBold20DarkGrey => GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF4F4F4F), height: 26 / 20, letterSpacing: -0.24);
  static TextStyle get extraBold20DarkGreyCompact => GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF4F4F4F), height: 22 / 20, letterSpacing: -0.4);

  // White (0xFFFFFFFF)
    static TextStyle get semiBold13White => GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color:  Colors.white, height: 20 / 14, letterSpacing: -0.24);
  static TextStyle get semiBold16White => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle get medium16White => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white);
  static TextStyle get regular16White => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white);
  static TextStyle get semiBold16WhiteCompact => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 22 / 16, letterSpacing: -0.4);
  static TextStyle get bold17White => GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, height: 26 / 17, letterSpacing: 0.1);

  // Primary Orange (0xFFFE8800)
  static TextStyle get regular14Primary => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFFFE8800));
  static TextStyle get bold14Primary => GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFE8800), height: 24 / 14);
  static TextStyle get semiBold16Primary => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFFE8800), height: 1.2);
  static TextStyle get extraBold16Primary => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFFFE8800));

  // Other Primary Orange (0xFFEF9F27)
  static TextStyle get semiBold16PrimaryDense => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFEF9F27), height: 12 / 16, letterSpacing: -0.2);

  // --- Orelega One ---
   static TextStyle get orelegaOne28DarkGrey => GoogleFonts.orelegaOne(fontSize: 28, fontWeight: FontWeight.w400, color: const Color(0xFF4F4F4F));
  static TextStyle get orelegaOne18DarkGrey => GoogleFonts.orelegaOne(fontSize: 18, fontWeight: FontWeight.w400, color: const Color(0xFF4F4F4F));
  static TextStyle get orelegaOne32White => GoogleFonts.orelegaOne(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.white);
  static TextStyle get orelegaOne32Grey => GoogleFonts.orelegaOne(fontSize: 32, fontWeight: FontWeight.w400, color: Color(0xFF838383));
  
  static TextStyle get orelegaOne32Primary => GoogleFonts.orelegaOne(fontSize: 32, fontWeight: FontWeight.w400, color: const Color(0xFFFE8800), height: 1.2);
  static TextStyle get orelegaOne30Primary => GoogleFonts.orelegaOne(fontSize: 30, fontWeight: FontWeight.w400, color: const Color(0xFFFE8800), height: 1.2);

  // --- Plus Jakarta Sans ---

  static TextStyle get plusJakartaSansSemiBold22Black => GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF1B1B1B), height: 30 / 22);
}
