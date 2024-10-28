import 'package:flutter/material.dart';

const Color hintColor = Color(0x33000000);

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFFAFAFA),
    primary: Color(0xFFFAFAFA),
    secondary: Color(0xFFFF6F61),
    secondaryFixedDim: Color(0x7FDCCCB4),
    tertiary: Color.fromARGB(127, 249, 237, 215),
    outline: Color(0xFF333333),
    inversePrimary: Color(0xFF333333),
    onSurface: hintColor,
    secondaryContainer: Color(0xFFFF8A61),
  ),
);
