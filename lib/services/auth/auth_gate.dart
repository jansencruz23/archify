import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/pages/day_space_page.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/no_moment_uploaded_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/settings_page.dart';
import 'package:archify/pages/day_space_page.dart';
import 'package:archify/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// To determine if login or home page
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
