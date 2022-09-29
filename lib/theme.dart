import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const colorScheme = ColorScheme.light(
  primary: Color.fromARGB(255, 55, 73, 233),
  onPrimary: Colors.white,
  secondary: Color.fromARGB(255, 20, 173, 122),
  onSecondary: Colors.white,
);

var themeData = ThemeData(
  useMaterial3: true,
  cardTheme: const CardTheme(
    color: Color(0xFFFFFFFF),
    surfaceTintColor: Color(0x118888FF),
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
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
