import 'package:flutter/material.dart';

const Color hintColor = Color(0x33000000);

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFFAFAFA), // bg
    primary: const Color(0xFFFAFAFA), // white
    secondary: const Color(0xFFFF6F61), //main orange
    secondaryFixedDim: const Color(0x7FDCCCB4),
    tertiary: const Color.fromARGB(127, 249, 237, 215),
    outline: Colors.grey[400],
    inversePrimary: const Color(0xFF333333), //Text Color
    onSurface: hintColor, // hint color for textfield
    secondaryContainer: const Color(0xFFFF8A61), //focused dim orange
    tertiaryContainer: const Color(0xFFE8E8E8), // focused dim white
  ),
);
