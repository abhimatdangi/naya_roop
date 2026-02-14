import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
const Color kPrimaryBlue = Color(0xFF007AFF);
const Color kDarkBackground = Color(0xFF000000);
const Color kLightBackground = Color(0xFFF2F2F7);
const Color kCardBackgroundLight = Colors.white;
const Color kCardBackgroundDark = Color(0xFF1C1C1E);
const Color kSubtleGray = Color(0xFFF2F2F7);
const Color kSecondaryLabel = Color(0xFF8E8E93);

// Dark/light mode toggle
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: kLightBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryBlue,
    primary: kPrimaryBlue,
    surface: kLightBackground,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.interTextTheme().copyWith(
    headlineMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: Colors.black,
      letterSpacing: -0.5,
    ),
    titleLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: Colors.black,
      letterSpacing: -0.3,
    ),
    titleMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    titleSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.inter(color: kSecondaryLabel),
    bodySmall: GoogleFonts.inter(color: kSecondaryLabel),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: kPrimaryBlue,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryBlue,
      foregroundColor: Colors.white,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: kPrimaryBlue,
      foregroundColor: Colors.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kPrimaryBlue,
      side: const BorderSide(color: kPrimaryBlue),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kDarkBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryBlue,
    primary: kPrimaryBlue,
    surface: kDarkBackground,
    brightness: Brightness.dark,
  ),
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
    headlineMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(221, 255, 255, 255),
    ),
    titleLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(221, 255, 255, 255),
    ),
    titleMedium: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(221, 255, 255, 255),
    ),
    titleSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      color: const Color.fromARGB(221, 255, 255, 255),
    ),
    bodyMedium: GoogleFonts.inter(color: Colors.white70),
    bodySmall: GoogleFonts.inter(color: Colors.white70),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: kPrimaryBlue,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryBlue,
      foregroundColor: Colors.white,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: kPrimaryBlue,
      foregroundColor: Colors.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kPrimaryBlue,
      side: const BorderSide(color: kPrimaryBlue),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
    ),
  ),
);
