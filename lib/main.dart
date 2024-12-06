import 'package:archify/firebase_options.dart';
import 'package:archify/services/auth/auth_gate.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:archify/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Firebase setup
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, DayProvider>(
          create: (context) => DayProvider(),
          update: (context, userProvider, dayProvider) =>
              dayProvider!..update(userProvider),
        ),
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
      routes: {'/': (context) => const AuthGate()},
    );
  }
}
