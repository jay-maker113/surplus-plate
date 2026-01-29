import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Scheme for Food Surplus App
const Color kPrimaryColor = Color(0xFF4CAF50); // Fresh green
const Color kSecondaryColor = Color(0xFFFF9800); // Warm orange
const Color kBackgroundColor = Color(0xFFFFFBFE); // Light cream
const Color kSurfaceColor = Colors.white;
const Color kErrorColor = Color(0xFFD32F2F); // Red

// Padding constants
const double kPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Border radius
const double kBorderRadius = 12.0;
const double kSmallBorderRadius = 8.0;

// Typography
TextStyle kHeadlineStyle = GoogleFonts.poppins(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

TextStyle kBodyStyle = GoogleFonts.roboto(
  fontSize: 16,
  color: Colors.black87,
);

TextStyle kButtonStyle = GoogleFonts.roboto(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);

// Custom ColorScheme
ColorScheme kColorScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: kPrimaryColor,
  onPrimary: Colors.white,
  secondary: kSecondaryColor,
  onSecondary: Colors.white,
  error: kErrorColor,
  onError: Colors.white,
  background: kBackgroundColor,
  onBackground: Colors.black87,
  surface: kSurfaceColor,
  onSurface: Colors.black87,
);
