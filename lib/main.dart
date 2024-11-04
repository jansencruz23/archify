import 'package:archify/firebase_options.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/register_page.dart';
import 'package:archify/pages/setup_page.dart';
import 'package:archify/pages/setup_pages/setup_intro_page.dart';
import 'package:archify/services/auth/auth_gate.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      initialRoute: '/',
      routes: {'/': (context) => RegisterPage(onTap: () {})},
    );
  }
}
