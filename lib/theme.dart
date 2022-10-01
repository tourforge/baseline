import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const colorScheme = ColorScheme.light(
  primary: Color.fromARGB(255, 29, 79, 145),
  onPrimary: Colors.white,
  secondary: Color.fromARGB(255, 20, 173, 122),
  onSecondary: Colors.white,
);

var themeData = ThemeData(
  cardTheme: const CardTheme(
    color: Color(0xFFFFFFFF),
    surfaceTintColor: Colors.white,
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
    button: GoogleFonts.robotoCondensed().copyWith(
      letterSpacing: 1.25,
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
  ),
  colorScheme: colorScheme,
);
