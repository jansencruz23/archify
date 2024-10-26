import 'package:archify/pages/setup_page.dart';
import 'package:flutter/material.dart';

// Helper para short code sa pag navigate thru pages

void goRootPage(BuildContext context) {
  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
}

void goSetup(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SetupPage()),
  );
}
