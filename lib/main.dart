import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:archify/firebase_options.dart';
import 'package:archify/services/auth/auth_gate.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:archify/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
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
      child: SplashScreen(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: AnimatedSplashScreen(
        splash: Image.asset('lib/assets/images/Logo.jpg'),
        splashIconSize: double.infinity,
        pageTransitionType: PageTransitionType.fade, // parang wa epek
        centered: true,
        nextScreen: MyApp(),
      ),
    );
  }
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
