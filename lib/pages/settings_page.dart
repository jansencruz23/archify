import 'dart:convert';
import 'package:archify/pages/about_us_page.dart';
import 'package:archify/pages/my_feedback_form.dart';
import 'package:flutter/foundation.dart';
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

class _SettingsPageState extends State<SettingsPage> {
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;
  late bool _setupNavigationTriggered;
  DateTime? minimumDate;

  int _selectedIndex = 0;
  bool _showVerticalBar = false;
  bool _isRotated = false;

  String subject = '';
  String body = '';
  String? _email; //how to get email

  late final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0,
    minLaunches: 0,
    googlePlayIdentifier: 'com.archify.app',
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _showVerticalBar = !_showVerticalBar;
      }
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupNavigationTriggered = false;

    _email = "";

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadUserProfile();
      // _checkIfNewUser();
    });
    @override
    void dispose() {
      super.dispose();
    }

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
  }

  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  //hover for button and mouse change
  bool amIHovering = false;
  Offset exitFrom = Offset(0, 0);

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
                  preferredSize: Size.fromHeight(70),
                  child: AppBar(
                    titleSpacing: 0,
                    leadingWidth: 500,
                    leading: SizedBox(
                      height: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.settings,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary), //Add ons --AAlfonso
                            SizedBox(width: 8),
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: _getClampedFontSize(context, 0.06),
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(1),
                      child: Divider(
                        height: 2,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )),

              //Copy of home page navbar
              bottomNavigationBar: false
                  ? null // Hide navbar when keyboard is visible
                  : MyNavbar(
                      selectedIndex: _selectedIndex,
                      onItemTapped: _onItemTapped,
                      showVerticalBar: _showVerticalBar,
                      isRotated: _isRotated,
                      toggleRotation: _toggleRotation,
                      // _isKeyboardVisible: _isKeyboardVisible, //NOTE: Need Key sa navbar para gumana
                    ),

              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
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
                          // print('Is dialog shown? $_isDialogShown'); // for debuging

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
                                        _rateMyApp.callEvent(RateMyAppEventType
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
                                        _rateMyApp.callEvent(RateMyAppEventType
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
                    ],
                  ),
                ),
              ),
            ));
    });
  }
}
