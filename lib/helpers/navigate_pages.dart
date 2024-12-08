import 'package:archify/models/day.dart';
import 'package:archify/pages/day_code_page.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/pages/day_space_page.dart';
import 'package:archify/pages/edit_day_settings_page.dart';
import 'package:archify/pages/edit_profile_page.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/setup_page.dart';
import 'package:archify/services/auth/auth_gate.dart';
import 'package:archify/services/database/day/day_gate.dart';
import 'package:flutter/material.dart';

// Helper para short code sa pag navigate thru pages

void goRootPage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const AuthGate()),
    (route) => false,
  );
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
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => DayCodePage(dayId: dayId)),
  );
}

void goDaySpace(BuildContext context, String dayCode) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DaySpacePage(dayCode: dayCode)),
    );
  });
}

void goHome(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
  );
}

void goDayGate(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DayGate()),
  );
}

void goProfile(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const ProfilePage()),
  );
}

void goEditProfile(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => EditProfilePage()),
  );
}

void goEditSettings(BuildContext context, Day day) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditDaySettingsPage(day: day)),
  );
}
