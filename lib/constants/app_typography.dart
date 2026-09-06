import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// NetLiv typography hierarchy using modern geometric Google Fonts (Poppins & Inter).
class AppTypography {
  static TextStyle get brandLogo => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: AppColors.textPrimary,
      );

  static TextStyle get brandTagline => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 4.0,
        color: AppColors.primaryLight,
      );

  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.15,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: Colors.white,
      );

  static TextStyle get chip => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get rankNumber => GoogleFonts.outfit(
        fontSize: 88,
        fontWeight: FontWeight.w900,
        color: Colors.transparent,
        letterSpacing: -6.0,
        height: 0.9,
      );

  // Netflix Landing OG Typographic Styles (matches images)
  static TextStyle get netflixHeroTitle => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1.18,
        letterSpacing: -0.5,
      );

  static TextStyle get netflixHeroSubtitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        height: 1.3,
      );

  static TextStyle get netflixSectionTitle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.2,
      );

  static TextStyle get netflixFaqQuestion => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get netflixFaqAnswer => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFE5E5E5),
        height: 1.45,
      );
}
