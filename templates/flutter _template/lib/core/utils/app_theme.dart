import 'package:flutter/material.dart';

/// Theme configuration for the app with Riverpod state management
class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0XFF08857C); // Dark green
  static const Color secondaryColor = Color(0xFF388E3C); // Medium green
  static const Color accentColor = Color(0xFF689F38); // Light green
  static const Color companyInfoColor = Color(0xFF65B4AF); // Teal

  // Background colors
  static const Color backgroundColor = Colors.white;

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    letterSpacing: 1.2,
    shadows: [
      Shadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
    ],
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    fontStyle: FontStyle.normal,
    color: secondaryColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    color: companyInfoColor, // Updated to teal color
    fontWeight: FontWeight.w500,
  );

  static const TextStyle smallTextStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: companyInfoColor, // Updated to teal color
    fontWeight: FontWeight.w400,
  );

  // AppBar constants
  static const double appBarHeight = 80.0;
  static const double appBarElevation = 0.0;
  static const Color appBarBackgroundColor = Colors.transparent;
  static const Color appBarTitleColor = Colors.black;
  static const double appBarTitleFontSize = 16.0;
  static const FontWeight appBarTitleFontWeight = FontWeight.w600;
  static const String appBarFontFamily = 'Montserrat';
  static const double appBarIconSize = 24.0;
  static const Color appBarIconColor = Colors.black;
  static const Color appBarSettingsIconColor = Colors.grey;

  // Button styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 2.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    textStyle: const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 1.5),
    elevation: 0.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    textStyle: const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    ),
  );

  // Card styling
  static const BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0, 2),
        blurRadius: 8.0,
        spreadRadius: 0,
      ),
    ],
  );

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      fontFamily: 'Montserrat', // Set Montserrat as the default font
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: headingStyle,
        bodyLarge: bodyTextStyle,
        bodyMedium: subheadingStyle,
        bodySmall: smallTextStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
    );
  }
}
