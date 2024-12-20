import 'package:archify/helpers/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/services/database/user/user_provider.dart';
import '../components/my_mobile_scanner_overlay.dart';
import '../helpers/navigate_pages.dart';
import '../models/day.dart';
import '../services/database/day/day_provider.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/settings_page.dart';

class DayExpiredPage extends StatefulWidget {
  final String dayCode;
  const DayExpiredPage({super.key, required this.dayCode});

  @override
  State<DayExpiredPage> createState() => _DayExpiredPageState();
}

class _DayExpiredPageState extends State<DayExpiredPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Day? day;
  late Day? _currentDay;

  int _selectedIndex = 1;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late final UserProvider _userProvider;
  late final DayProvider _dayProvider;

  //Qrcode string
  String qrCode = '';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.wb_sunny, 'title': 'Enter a day code'},
    {'icon': Icons.qr_code_scanner, 'title': 'Scan QR code'},
    {'icon': Icons.add_circle_outline, 'title': 'Create a day'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      Route customRoute(Widget page, Offset startOffset) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
            Tween(begin: startOffset, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      }

      if (index == 0) {
        Navigator.pushReplacement(
          context,
          customRoute(HomePage(), Offset(-1.0, 0.0)), // navigate from left to right
        );
      } else if (index == 2) {
        if (_showVerticalBar) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
        _showVerticalBar = !_showVerticalBar;
      } else if (_showVerticalBar) {
        _animationController.reverse();
        _showVerticalBar = false;
      } else if (index == 3) {
        Navigator.pushReplacement(
          context,
          customRoute(ProfilePage(), Offset(1.0, 0.0)), // navigate from right to left
        );
      } else if (index == 4) {
        Navigator.pushReplacement(
          context,
          customRoute(SettingsPage(), Offset(1.0, 0.0)), // navigate from right to left
        );
      }
    });
  }

  Future<void> _loadCurrentDay() async {
    await _userProvider.updateCurrentDay();
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

  //QR Scanner
  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onScan: (String code) async {
            setState(() {
              qrCode = code;
            });
            final isExisting = await _dayProvider.isDayExistingAndActive(code);

            if (isExisting && mounted) {
              goDaySpace(context, qrCode);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Day does not exist or already finished'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _dayProvider = Provider.of<DayProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _controller = AnimationController(vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider.updateCurrentDay();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final userListeningProvider = Provider.of<UserProvider>(context);
    day = listeningProvider.day;
    _currentDay = userListeningProvider.currentDay;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          titleSpacing: 0,
          leadingWidth: 600,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
            child: Stack(
              children: [
                Text(
                  'Let’s keep the moment,',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 12,
                  ),
                ),
                Positioned(
                  bottom: -6,
                  left: 0,
                  child: Text(
                    'Pick the best shot!',
                    style: TextStyle(
                      fontSize: getClampedFontSize(context, 0.05),
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(5),
            child: Divider(
              height: 5,
              color: Color(0xFFD9D9D9),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
           Row(
             children: [
               Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(10.0),
                     color: Theme.of(context).colorScheme.secondary,
                   ),
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text(
                       'DAY CODE: ${widget.dayCode}',
                       style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.bold,
                         color: Theme.of(context).colorScheme.surface,
                       ),
                     ),
                   ),        ),
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
                      fontFamily: 'Sora',
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: getClampedFontSize(context, 0.05),
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
                              child: GestureDetector(
                                onTap: _currentDay != null
                                    ? () {}
                                    : () {
                                        if (item['title'] ==
                                            'Enter a day code') {
                                          _showEnterDayCodeDialog(context);
                                        } else if (item['title'] ==
                                            'Create a day') {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DaySettingsPage()),
                                          );
                                        } else if (item['title'] ==
                                            'Scan QR code') {
                                          _scanQRCode();
                                        }
                                      },
                                child: ListTile(
                                  leading: Icon(
                                    item['icon'],
                                    color: _currentDay != null
                                        ? Colors.grey[300]
                                        : Colors.white,
                                  ),
                                  title: Text(
                                    item['title'],
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      color: _currentDay != null
                                          ? Colors.grey[300]
                                          : Colors.white,
                                      fontSize: 14,
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
