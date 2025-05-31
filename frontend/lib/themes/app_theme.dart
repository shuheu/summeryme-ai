import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0056CC);
  static const Color primaryLight = Color(0xFF4DA3FF);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF007AFF),
    Color(0xFF5856D6),
    Color(0xFFAF52DE),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF4A90E2),
    Color(0xFF357ABD),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF4A90A4),
    Color(0xFF357A8A),
  ];

  static const List<Color> successGradient = [
    Color(0xFF6B8E23),
    Color(0xFF556B2F),
  ];

  // Background Colors
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8F9FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);

  // Border Colors
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Shadow Colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.1);
  static Color shadowDark = Colors.black.withValues(alpha: 0.2);
}

class AppTextStyles {
  // Headlines
  static TextStyle headline1(bool isTablet) => TextStyle(
        fontSize: isTablet ? 32 : 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle headline2(bool isTablet) => TextStyle(
        fontSize: isTablet ? 28 : 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle headline3(bool isTablet) => TextStyle(
        fontSize: isTablet ? 24 : 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // Body Text
  static TextStyle bodyLarge(bool isTablet) => TextStyle(
        fontSize: isTablet ? 18 : 16,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle bodyMedium(bool isTablet) => TextStyle(
        fontSize: isTablet ? 16 : 14,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle bodySmall(bool isTablet) => TextStyle(
        fontSize: isTablet ? 14 : 12,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Labels
  static TextStyle labelLarge(bool isTablet) => TextStyle(
        fontSize: isTablet ? 18 : 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle labelMedium(bool isTablet) => TextStyle(
        fontSize: isTablet ? 16 : 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle labelSmall(bool isTablet) => TextStyle(
        fontSize: isTablet ? 12 : 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  // Caption
  static TextStyle caption(bool isTablet) => TextStyle(
        fontSize: isTablet ? 14 : 12,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant,
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: AppColors.shadowLight,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AppGradients {
  static LinearGradient get primary => const LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get secondary => const LinearGradient(
        colors: AppColors.secondaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accent => const LinearGradient(
        colors: AppColors.accentGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get success => const LinearGradient(
        colors: AppColors.successGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppShadows {
  static List<BoxShadow> get light => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get heavy => [
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];
}

// Responsive helper
class AppResponsive {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  static double getMaxWidth(BuildContext context) {
    return isTablet(context) ? 800.0 : double.infinity;
  }

  static EdgeInsets getPadding(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    return EdgeInsets.all(isTablet ? 24.0 : 16.0);
  }

  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    return EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0);
  }
}
