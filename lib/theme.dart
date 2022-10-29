import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const colorScheme = ColorScheme.light(
  primary: Color.fromARGB(255, 29, 79, 145),
  secondary: Color.fromARGB(255, 20, 173, 122),
  onPrimary: Color.fromARGB(255, 211, 233, 255),
  onSecondary: Colors.white,
);

ThemeData get themeData => ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xfff8f8f8),
      cardTheme: const CardTheme(
        color: Color(0xFFFFFFFF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          ),
          backgroundColor: MaterialStateProperty.all(colorScheme.primary),
          foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
          overlayColor: MaterialStateProperty.all(const Color(0x20FFFFFF)),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: GoogleFonts.lexend(
          color: Colors.black,
          fontSize: 25.0,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: GoogleFonts.lexend(
          color: Colors.black,
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.lexend(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.lexend(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.openSans(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 14.0,
          letterSpacing: 1.1,
        ),
        labelMedium: GoogleFonts.openSans(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 12.0,
          letterSpacing: 1.5,
        ),
        labelSmall: GoogleFonts.openSans(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 11.0,
          letterSpacing: 1.5,
        ),
        bodyLarge: GoogleFonts.openSans(
          color: Colors.black,
          fontSize: 15.0,
        ),
        bodyMedium: GoogleFonts.openSans(
          color: Colors.black,
          fontSize: 14.0,
        ),
        bodySmall: GoogleFonts.openSans(
          color: Colors.black,
          fontSize: 12.0,
        ),
      ),
      colorScheme: colorScheme,
      sliderTheme: const SliderThemeData(
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 32, 32, 48),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
    );
