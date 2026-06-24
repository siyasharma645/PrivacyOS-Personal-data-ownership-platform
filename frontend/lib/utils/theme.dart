import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const brand = Color(0xFF6366F1);
  static const brandLight = Color(0xFF818CF8);
  static const brandDark = Color(0xFF4F46E5);

  // Surface
  static const bg = Color(0xFF09090B);
  static const surface = Color(0xFF18181B);
  static const surface2 = Color(0xFF27272A);
  static const surface3 = Color(0xFF3F3F46);
  static const border = Color(0xFF3F3F46);

  // Text
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textMuted = Color(0xFF71717A);

  // Risk
  static const low = Color(0xFF22C55E);
  static const medium = Color(0xFFF59E0B);
  static const high = Color(0xFFF97316);
  static const critical = Color(0xFFEF4444);

  // Severity
  static const info = Color(0xFF3B82F6);
  static const warning = Color(0xFFF59E0B);

  static Color riskColor(String level) {
    switch (level.toUpperCase()) {
      case 'LOW': return low;
      case 'MEDIUM': return medium;
      case 'HIGH': return high;
      case 'CRITICAL': return critical;
      default: return textMuted;
    }
  }

  static Color scoreColor(int score) {
    if (score >= 80) return low;
    if (score >= 60) return medium;
    if (score >= 40) return high;
    return critical;
  }

  static Color providerColor(String provider) {
    switch (provider.toUpperCase()) {
      case 'GOOGLE': return const Color(0xFF4285F4);
      case 'GITHUB': return const Color(0xFF6E40C9);
      case 'LINKEDIN': return const Color(0xFF0A66C2);
      case 'FACEBOOK': return const Color(0xFF1877F2);
      case 'TWITTER': return const Color(0xFF1DA1F2);
      case 'MICROSOFT': return const Color(0xFF00A4EF);
      default: return brand;
    }
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.brand,
        secondary: AppColors.brandLight,
        surface: AppColors.surface,
        background: AppColors.bg,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
          headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
          titleSmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
          bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 12),
          labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
          labelSmall: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.8),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.critical),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: Color(0x1A6366F1),
        selectedIconTheme: IconThemeData(color: AppColors.brandLight),
        unselectedIconTheme: IconThemeData(color: AppColors.textMuted),
        selectedLabelTextStyle: TextStyle(color: AppColors.brandLight, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: AppColors.textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface2,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface2,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
    );
  }
}
