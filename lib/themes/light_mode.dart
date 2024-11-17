import 'package:flutter/material.dart';

const Color hintColor = Color(0x33000000);

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFFAFAFA),
    primary: const Color(0xFFFAFAFA),
    secondary: const Color(0xFFFF6F61),
    secondaryFixedDim: const Color(0x7FDCCCB4),
    tertiary: const Color.fromARGB(127, 249, 237, 215),
    outline: Colors.grey[400],
    inversePrimary: const Color(0xFF333333),
    onSurface: hintColor,
    secondaryContainer: const Color(0xFFFF8A61),
  ),
);
