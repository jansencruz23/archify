import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/services/database/user/user_provider.dart';
import '../models/day.dart';
import '../services/database/day/day_provider.dart';

class DayExpiredPage extends StatefulWidget {
  const DayExpiredPage({super.key});

  @override
  State<DayExpiredPage> createState() => _DayExpiredPageState();
}

class _DayExpiredPageState extends State<DayExpiredPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Day? day;
  int _selectedIndex = 1;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.wb_sunny, 'title': 'Enter a day code'},
    {'icon': Icons.qr_code_scanner, 'title': 'Scan QR code'},
    {'icon': Icons.add_circle_outline, 'title': 'Create a day'},
    {'icon': Icons.settings, 'title': 'Settings'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        // Toggle the visibility of the vertical bar
        print("Tapped 'Create a day'");  // Debugging line
        if (_showVerticalBar) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
        _showVerticalBar = !_showVerticalBar;
      } else {
        // Close the vertical bar if any other menu item is tapped
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
    });
  }

  void _showEnterDayCodeDialog(BuildContext context) {
    TextEditingController _codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFF6F61),
          title: const Text(
            'Enter Day Code',
            style: TextStyle(fontFamily: 'Sora', color: Colors.white),
          ),
          content: TextField(
            controller: _codeController,
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              hintText: 'Enter your code',
              hintStyle: TextStyle(fontFamily: 'Sora', color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(fontFamily: 'Sora', color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Sora', color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                String enteredCode = _codeController.text;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Code Entered: $enteredCode',
                      style: const TextStyle(fontFamily: 'Sora'),
                    ),
                  ),
                );
              },
              child: const Text(
                'Enter',
                style: TextStyle(fontFamily: 'Sora', color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }


  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    day = listeningProvider.day;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          titleSpacing: 0,
          leadingWidth: 600,
          leading: SizedBox(
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Stack(
                children: [
                  Text(
                    'Let’s keep the moment,',
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.01),
                      fontFamily: 'Sora',
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    child: Text(
                      'Pick the best shot!',
                      style: TextStyle(
                        fontSize: _getClampedFontSize(context, 0.06),
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 2,
              color: Colors.grey,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'DAY CODE: ${day?.code == null ? 'Join a new day' : day!.code}',
                      style: TextStyle(
                        fontSize: _getClampedFontSize(context, 0.03),
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('lib/assets/images/Trophy.png'),
                  const SizedBox(height: 10),
                  Text(
                    'The photo battle is over—see the winning moment!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.05),
                      fontFamily: 'Sora',
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              showEnterDayCodeDialog: _showEnterDayCodeDialog,
            ),
          ),
          if (_showVerticalBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: (_menuItems.length * 50).toDouble() + 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6F61),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _animationController.reverse();
                              _showVerticalBar = false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _menuItems.length,
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            return ListTile(
                              leading: Icon(item['icon'], color: Colors.white),
                              title: Text(item['title'], style: const TextStyle(fontFamily: 'Sora', color: Colors.white)),
                              onTap: () {
                                if (item['title'] == 'Enter a day code') {
                                  _showEnterDayCodeDialog(context);
                                } else if (item['title'] == 'Create a day') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DaySettingsPage()),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
