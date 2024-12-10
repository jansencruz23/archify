import 'dart:convert';
import 'package:archify/components/my_mobile_scanner_overlay.dart';
import 'package:archify/helpers/font_helper.dart';
import 'package:archify/models/day.dart';
import 'package:archify/pages/about_us_page.dart';
import 'package:archify/pages/my_feedback_form.dart';
import 'package:archify/services/database/day/day_gate.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/pages/my_feedback_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/components/my_settings_button.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archify/pages/terms_and_condition_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class DoNotOpenAgainCondition {
  bool? doNotOpenAgain; // Nullable to avoid LateInitializationError

  void saveToPreferences() {
    // Ensure that doNotOpenAgain is set before accessing
    doNotOpenAgain ??= false; // Default value if not set already
    // Your save logic here
  }
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late bool _setupNavigationTriggered;
  DateTime? minimumDate;
  late final DayProvider _dayProvider;
  late final UserProvider _userProvider;
  late Day? _currentDay;

  String subject = '';
  String body = '';
  String? _email; //how to get email
  final bool _isDialogShown = false;

  late final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0,
    minLaunches: 0,
    googlePlayIdentifier: 'com.archify.app',
  );

  int _selectedIndex = 4;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  int _hoveredIndex = -1;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

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

      Route customRoute(Widget page) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // from left magna-navigate
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

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
          customRoute(HomePage()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          customRoute(DayGate()),
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
          customRoute(ProfilePage()),
        );
      }
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
    });
  }

  Future<void> _loadCurrentDay() async {
    await _userProvider.updateCurrentDay();
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
            style: TextStyle(
              fontFamily: 'Sora',
              color: Colors.white,
            ),
          ),
          content: TextField(
            controller: _codeController,
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              hintText: 'Enter your code',
              hintStyle: TextStyle(
                fontFamily: 'Sora',
                color: Colors.white70,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Sora',
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Sora',
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String enteredCode = _codeController.text;
                Navigator.pop(context);
                await joinDay(enteredCode);
              },
              child: const Text(
                'Enter',
                style: TextStyle(
                  fontFamily: 'Sora',
                  color: Colors.white,
                ),
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
    // TODO: implement initState
    super.initState();

    _dayProvider = Provider.of<DayProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOut));
    _setupNavigationTriggered = false;

    _email = "";

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Off-screen (bottom)
      end: const Offset(0, 0), // On-screen
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider.updateCurrentDay();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //hover for button and mouse change
  bool amIHovering = false;
  Offset exitFrom = Offset(0, 0);

  Future<void> _logout() async {
    await AuthService().logoutInFirebase();
    _dayProvider.resetDay();
    _userProvider.resetUserProfile();
    if (mounted) goRootPage(context);
  }

  //fetching ng email -AAlfonso
  Future<void> _fetchUserEmail() async {
    final user = AuthService().getCurrentUser();
    debugPrint('User: $user');
    debugPrint('User Email: ${user?.email}');
    setState(() {
      _email = user?.email ?? 'Email not available';
    });
  }

  // for rating pop up
  void initializeDate() {
    minimumDate = DateTime.now();
  }

  Future<void> joinDay(String dayCode) async {
    if (dayCode.isEmpty) return;
    final dayExists = await _dayProvider.isDayExistingAndActive(dayCode);
    final isRoomFull = await _dayProvider.isRoomFull(dayCode);

    if (!mounted) return;

    if (isRoomFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room is full')),
      );
      return;
    }

    if (!dayExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day does not exist or already finished')),
      );
      return;
    }

    goDaySpace(context, dayCode);
  }

  @override
  Widget build(BuildContext context) {
    final _userListeningProvider = Provider.of<UserProvider>(context);
    _currentDay = _userListeningProvider.currentDay;

    return SafeArea(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 33.0),
          alignment: Alignment.centerLeft,
          child: SafeArea(
            child: Text(
              "Settings",
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: getClampedFontSize(context, 0.05),
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                MySettingsButton(
                  text: 'Rate Us',
                  icon: Image.asset(
                    'lib/assets/images/rate_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    // print('rate');
                    print('Is dialog shown? $_isDialogShown'); // for debuging

                    _rateMyApp.showStarRateDialog(
                      context,
                      title: 'Enjoying Archify?',
                      message: 'Please leave a rating!',
                      dialogStyle: DialogStyle(
                        titleAlign: TextAlign.center, // Align the title text
                        titleStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .inversePrimary, // Set the title color
                          fontWeight: FontWeight
                              .bold, // Set additional styles if needed
                          fontSize: getClampedFontSize(context, 0.04),
                          fontFamily: 'Sora',
                        ),
                        messageAlign:
                            TextAlign.center, // Align the message text
                        messageStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .inversePrimary, // Set the message color
                          fontFamily: 'Sora',
                        ),
                      ),
                      actionsBuilder: (context, stars) {
                        return [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _rateMyApp.callEvent(
                                      RateMyAppEventType.laterButtonPressed);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Later',
                                  style: TextStyle(
                                    color: Color(0xFFFF6F61),
                                    fontFamily: 'Sora',
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _rateMyApp.callEvent(
                                      RateMyAppEventType.rateButtonPressed);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Rate Now',
                                  style: TextStyle(
                                    color: Color(0xFFFF6F61),
                                    fontFamily: 'Sora',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ];
                      },
                    );
                  },
                ),
                MySettingsButton(
                  text: 'Share App',
                  icon: Image.asset(
                    'lib/assets/images/share_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () async {
                    //pang share ng link from appstore or google playstore but hindi publish app natin
                    Share.share('com.archify.app');
                  },
                ),
                MySettingsButton(
                  text: 'Privacy Policy',
                  icon: Image.asset(
                    'lib/assets/images/privacy_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: TermsAndConditionsPage(),
                        );
                      },
                    );
                  },
                ),
                MySettingsButton(
                  text: 'About Us',
                  icon: Image.asset(
                    'lib/assets/images/about_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: AboutUsPage(),
                        );
                      },
                    );
                  },
                ),
                MySettingsButton(
                  text: 'Contact Us',
                  icon: Image.asset(
                    'lib/assets/images/contact_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'archify.app@gmail.com',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold,
                                fontSize: getClampedFontSize(context, 0.04),
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                          content: Text(
                            'Feel free to contact us via our email!',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Center(
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6F61)),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                MySettingsButton(
                  text: 'Feedback',
                  icon: Image.asset(
                    'lib/assets/images/feedback_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: MyFeedbackForm(
                              onSubmit: (String subject, String body) {
                            debugPrint('Subject: $subject');
                            debugPrint('Body: $body');
                          }),
                        );
                      },
                    );
                  },
                ),
                MySettingsButton(
                  text: 'Log Out',
                  icon: Image.asset(
                    'lib/assets/images/logout_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    _logout();
                  },
                ),
                const SizedBox(height: 300),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom)),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            child: MyNavbar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              showVerticalBar: _showVerticalBar,
              isRotated: _isRotated,
              toggleRotation: _toggleRotation,
              showEnterDayCodeDialog: _showEnterDayCodeDialog,
              updateCurrentDay: _loadCurrentDay,
            ),
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
                                      if (item['title'] == 'Enter a day code') {
                                        _showEnterDayCodeDialog(context);
                                      } else if (item['title'] ==
                                          'Create a day') {
                                        Navigator.push(
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
      ]),
    ));
  }
}
