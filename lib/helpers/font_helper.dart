import 'package:flutter/material.dart';

//For Responsiveness
double getClampedFontSize(BuildContext context, double scale) {
  double calculatedFontSize = MediaQuery.of(context).size.width * scale;
  return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
}
