import 'dart:convert';
import 'package:archify/pages/about_us_page.dart';
import 'package:archify/pages/my_feedback_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/home_page.dart';
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
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;
  late bool _setupNavigationTriggered;
  DateTime? minimumDate;

  String subject = '';
  String body = '';
  String? _email; //how to get email
  bool _isDialogShown = false;

  late final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0,
    minLaunches: 0,
    googlePlayIdentifier: 'com.archify.app',
  );

  int _selectedIndex = 0;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  int _hoveredIndex = -1;
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
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmptyDayPage()),
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

  @override
  void initState() {
    super.initState();
    _setupNavigationTriggered = false;

    _email = "";

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadUserProfile();
      // _checkIfNewUser();
    });

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  //hover for button and mouse change
  bool amIHovering = false;
  Offset exitFrom = Offset(0, 0);

  Future<void> _loadUserProfile() async {
    await _userProvider.loadUserProfile();
  }

  Future<void> _checkIfNewUser() async {
    if (_setupNavigationTriggered) return;

    final user = await _userProvider.getCurrentUserProfile();

    if (user != null && user.isNew) {
      _setupNavigationTriggered = true;
      if (mounted) {
        goSetup(context);
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().logoutInFirebase();
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

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<UserProvider>(context);
    final userProfile = listeningProvider.userProfile;

    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return _userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                  child: const SafeArea(
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 23,
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
                          icon: Icon(
                            Icons.star_border_outlined,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          onTap: () {
                            // print('rate');
                            print(
                                'Is dialog shown? $_isDialogShown'); // for debuging

                            _rateMyApp.showStarRateDialog(
                              context,
                              title: 'Enjoying Archify?',
                              message: 'Please leave a rating!',
                              dialogStyle: DialogStyle(
                                titleAlign:
                                    TextAlign.center, // Align the title text
                                titleStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary, // Set the title color
                                  fontWeight: FontWeight
                                      .bold, // Set additional styles if needed
                                  fontSize: 20.0,
                                ),
                                messageAlign:
                                    TextAlign.center, // Align the message text
                                messageStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary, // Set the message color
                                  fontSize: 16.0,
                                ),
                              ),
                              actionsBuilder: (context, stars) {
                                return [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _rateMyApp.callEvent(
                                              RateMyAppEventType
                                                  .laterButtonPressed);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Later',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _rateMyApp.callEvent(
                                              RateMyAppEventType
                                                  .rateButtonPressed);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Rate Now',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary),
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
                          text: 'Share',
                          icon: Icon(Icons.share_outlined,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                          onTap: () async {
                            //pang share ng link from appstore or google playstore but hindi publish app natin
                            Share.share('com.archify.app');
                          },
                        ),
                        MySettingsButton(
                          text: 'Privacy',
                          icon: Icon(Icons.lock_outline_sharp,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
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
                          text: 'About',
                          icon: Icon(Icons.file_present_outlined,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
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
                          text: 'Contact',
                          icon: Icon(Icons.mail_outline_rounded,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'archify.app@gmail.com',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary),
                                  ),
                                  content: Text(
                                    'Feel free to contact us via our email!',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Center(
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary),
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
                          icon: Icon(Icons.feedback_outlined,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
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
                          text: 'Logout',
                          icon: Icon(Icons.logout,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                          onTap: () {
                            _logout();
                          },
                        ),
                        const SizedBox(height: 300),
                        Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom)),
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
                                        if (item['title'] ==
                                            'Enter a day code') {
                                          _showEnterDayCodeDialog(context);
                                        } else if (item['title'] ==
                                            'Create a day') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DaySettingsPage()),
                                          );
                                        }
                                      },
                                      child: ListTile(
                                        leading: Icon(
                                          item['icon'],
                                          color: Colors.white,
                                        ),
                                        title: Text(
                                          item['title'],
                                          style: const TextStyle(
                                            fontFamily: 'Sora',
                                            color: Colors.white,
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
    });
  }
}
