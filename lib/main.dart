import 'package:archify/firebase_options.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/services/notification/fcm_service.dart';
import 'package:archify/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService.setupFCM();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => DayProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // Off-screen (right)
      end: Offset.zero,          // On-screen
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      print('Animation status: $status');
    });

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        if (_showVerticalBar) {
          print('Reversing animation');
          _animationController.reverse();
        } else {
          print('Starting animation');
          _animationController.forward();
        }
        _showVerticalBar = !_showVerticalBar;
      } else {
        if (_showVerticalBar) {
          _animationController.reverse();
          _showVerticalBar = false;
        }
      }
      _selectedIndex = index;
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
      print('Is Rotated: $_isRotated');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: Scaffold(
        body: Stack(
          children: [
            // Main screen content
            Center(
              child: Text('Selected Index: $_selectedIndex'),
            ),
            // Add the vertical bar here
            if (_showVerticalBar)
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: 60,
                    color: Colors.blue, // Customize the bar
                  ),
                ),
              ),
            // Navbar at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MyNavbar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
                showVerticalBar: _showVerticalBar,
                isRotated: _isRotated,
                toggleRotation: _toggleRotation,
              ),
            ),
          ],
        ),
      ),
    );
  }
  }