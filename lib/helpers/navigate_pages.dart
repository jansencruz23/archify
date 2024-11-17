import 'package:archify/pages/day_code_page.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/pages/day_space_page.dart';
import 'package:archify/pages/join_page.dart';
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

void goDaySettings(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DaySettingsPage()),
  );
}

void goDayCode(BuildContext context, String dayId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DayCodePage(dayId: dayId)),
  );
}

void goJoin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const JoinPage()),
  );
}

void goDaySpace(BuildContext context, String dayId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DaySpacePage(dayId: dayId)),
  );
}
