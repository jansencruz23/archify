import 'package:archify/helpers/font_helper.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/services/database/day/day_gate.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/settings_page.dart';
import 'package:provider/provider.dart';

class MyNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool showVerticalBar;
  final bool isRotated;
  final Function toggleRotation;
  final Function(BuildContext)? showEnterDayCodeDialog;
  final void Function()? updateCurrentDay;

  const MyNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.showVerticalBar,
    required this.isRotated,
    required this.toggleRotation,
    this.showEnterDayCodeDialog,
    this.updateCurrentDay,
  });

  static const double navIconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 80,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavIcon('lib/assets/images/home_icon.png', 0),
            _buildNavIcon('lib/assets/images/like_icon.png', 1),
            _buildElevatedNavIcon(),
            _buildNavIcon('lib/assets/images/user_icon.png', 3),
            _buildNavIcon('lib/assets/images/setting_icon.png', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(String assetPath, int index) {
    return GestureDetector(
      onTap: () {
        // Only update the selectedIndex if it's not index 2
        if (index != 2) {
          onItemTapped(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: navIconSize,
            height: navIconSize,
          ),
          // Show the dot only for the selectedIndex and exclude index 2
          if (selectedIndex == index && selectedIndex != 2)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6F61),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildElevatedNavIcon() {
    return GestureDetector(
      onTap: () {
        if (updateCurrentDay != null) {
          updateCurrentDay!();
        }
        toggleRotation();
        onItemTapped(2);
      },
      child: Transform.translate(
        offset: const Offset(0, -15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF5DEB3),
                    Color(0xFFD2691E),
                    Color(0xFFFF6F61),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isRotated ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Color(0xFFD2691E),
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  int _hoveredIndex = -1;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late DayProvider _dayProvider;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.wb_sunny, 'title': 'Enter a day code'},
    {'icon': Icons.qr_code_scanner, 'title': 'Scan QR code'},
    {'icon': Icons.add_circle_outline, 'title': 'Create a day'},
    {'icon': Icons.settings, 'title': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    _dayProvider = Provider.of<DayProvider>(context, listen: false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOut));

    _animationController.addStatusListener((status) {
      print('Animation status: $status');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DayGate()),
        );
      } else if (index == 2) {
        if (_showVerticalBar) {
          print('Reversing animation');
          _animationController.reverse();
        } else {
          print('Starting animation');
          _animationController.forward();
        }
        _showVerticalBar = !_showVerticalBar;
      } else if (_showVerticalBar) {
        _animationController.reverse();
        _showVerticalBar = false;
      } else if (index == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } else if (index == 4) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
      }
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
    });
  }

  void _showEnterDayCodeDialog(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFF6F61),
          title: Text(
            'Enter Day Code',
            style: TextStyle(
              fontFamily: 'Sora',
              color: Colors.white,
              fontSize: getClampedFontSize(context, 0.3),
            ),
          ),
          content: TextField(
            controller: codeController,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Enter your code',
              hintStyle: TextStyle(
                fontFamily: 'Sora',
                color: Colors.white70,
                fontSize: getClampedFontSize(context, 0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(
              fontFamily: 'Sora',
              color: Colors.white,
              fontSize: getClampedFontSize(context, 0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Sora',
                  color: Colors.white,
                  fontSize: getClampedFontSize(context, 0),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String enteredCode = codeController.text;
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
              child: Text(
                'Enter',
                style: TextStyle(
                  fontFamily: 'Sora',
                  color: Colors.white,
                  fontSize: getClampedFontSize(context, 0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                  height: (_menuItems.length * 45).toDouble() + 100,
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
                          icon: const Icon(Icons.keyboard_arrow_down,
                              size: 30, color: Colors.white),
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
                            return MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _hoveredIndex = index;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _hoveredIndex = -1;
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (item['title'] == 'Enter a day code') {
                                    _showEnterDayCodeDialog(context);
                                  }
                                },
                                child: ListTile(
                                  leading: Icon(
                                    item['icon'],
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    item['title'],
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      color: Colors.white,
                                      fontSize: getClampedFontSize(context, 0),
                                    ),
                                  ),
                                ),
                              ),
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
