import 'dart:async';

import 'package:archify/components/my_comment_text_field.dart';
import 'package:archify/components/my_day.dart';
import 'package:archify/components/my_mobile_scanner_overlay.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_nickname_and_avatar_dialog.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/models/day.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/settings_page.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/day/day_gate.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getwidget/getwidget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../components/my_text_field.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:archify/components/my_nickname_and_avatar_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  //Testing NicknameAndAvatar Dialog
  void _showNicknameAndAvatarDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Select a Photo and Enter Nickanme'),
              content: Container(
                width: double.infinity,
                child: MyNicknameAndAvatarDialog(
                  nicknameController: _nicknameController,
                  avatarController: _avatarController,
                  onSubmit: () {},
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'))
              ],
            ));
  }

// Text lang ng nickname and avatar
  late final TextEditingController _nicknameController =
      TextEditingController();
  late final TextEditingController _avatarController = TextEditingController();

  late final AuthProvider _authProvider;
  late final DayProvider _dayProvider;
  late final UserProvider _userProvider;
  late bool _setupNavigationTriggered;
  late Day? _currentDay;

  bool _isKeyboardVisible =
      false; //For Keyboard to remove navbar visibility -AAlfonso
  int _selectedIndex = 0;
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
            const begin = Offset(1.0, 0.0); // from right magna-navigate
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

      if (index == 1) {
        Navigator.pushReplacement(
          context,
          customRoute(DayGate()), // transition to EmptyDayPage
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
          customRoute(ProfilePage()), // transition to ProfilePage
        );
      } else if (index == 4) {
        Navigator.pushReplacement(
          context,
          customRoute(SettingsPage()), // transition to SettingsPage
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
          title: const Text(
            'Enter Day Code',
            style: TextStyle(
              fontFamily: 'Sora',
              color: Colors.white,
            ),
          ),
          content: TextField(
            controller: codeController,
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
                String enteredCode = codeController.text;
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
          onScan: (String code) {
            setState(() {
              qrCode = code;
            });
            goDaySpace(context, qrCode);
            Navigator.pop(context);
          },
        ),
      ),
    );
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

  final CarouselController _carouselController = CarouselController();
  String _currentDayId = '';
  int _currentIndex = 0; // Track the current index
  int realIndex = 0; // To store real index
  bool _isInitialLoad = true;

  late final TextEditingController _commentController;
  late final FocusNode _fieldComment;

  @override
  void initState() {
    super.initState();
    _setupNavigationTriggered = false;
    _fieldComment = FocusNode();
    _commentController = TextEditingController();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _dayProvider = Provider.of<DayProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _checkIfNewUser();
      //_startCountdown();
    });

    _fieldComment.addListener(() {
      setState(() {
        _isKeyboardVisible = _fieldComment.hasFocus;
      });
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
    _commentController.dispose();
    _fieldComment.dispose();
    _animationController.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadCurrentDay();
    await _loadUserProfile();
    await _loadUserMoments();
    _refreshComments();
  }

  void _refreshComments() async {
    _dayProvider.refreshComments();
  }

  Future<void> _loadUserMoments() async {
    await _userProvider.loadUserMoments();
  }

  Future<void> _loadCurrentDay() async {
    await _userProvider.updateCurrentDay();
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.loadUserProfile();
  }

  // Future<dynamic> _showVotingDeadline(BuildContext context, String? timeLeft) {

  // }

  Future<void> _sendComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;
    if (_currentDayId.isEmpty) return;

    await _dayProvider.sendComment(comment, _currentDayId);
    _commentController.clear();
  }

  Future<void> _toggleFavorites() async {
    if (_currentDayId.isEmpty) return;

    await _userProvider.toggleFavorites(_currentDayId);
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

  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Ang min and max nyaa
  }

  //Out ng comment textfield pag click anywhere
  void _unfocusAllFields() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final userListeningProvider = Provider.of<UserProvider>(context);
    final dayListeningProvider = Provider.of<DayProvider>(context);
    _currentDay = userListeningProvider.currentDay;
    final userProfile = userListeningProvider.userProfile;
    final days = userListeningProvider.moments;
    if (_isInitialLoad && days.isNotEmpty) {
      _currentDayId = days.isEmpty ? '' : days[0].dayId;
    }
    dayListeningProvider.listenToComments(_currentDayId);
    final comments = dayListeningProvider.commentsByDayId;

    return GestureDetector(
        onTap: () {
          _fieldComment.unfocus();
        },
        child: SafeArea(
          child: Scaffold(
            //AppBar with custom height
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: AppBar(
                  // Leading section with profile picture and welcome text
                  titleSpacing: 0,
                  leadingWidth: 80,
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile picture widget
                        MyProfilePicture(
                          height: 80,
                          width: 80,
                          onProfileTapped: () {},
                        ),
                      ],
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 24.0, 8.0, 14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome back text
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: _getClampedFontSize(context, 0.03),
                          ),
                        ),
                        // User's name text
                        Text(
                          userProfile == null ? 'Loading' : userProfile.name,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.bold,
                            fontSize: _getClampedFontSize(context, 0.045),
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification icon button
                  actions: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 14, 7, 0),
                      child: IconButton(
                        onPressed: () {
                          _showNicknameAndAvatarDialog(context);
                        },
                        icon: Image.asset(
                          'lib/assets/images/notification_icon.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(5),
                    child: Divider(
                      height: 5,
                      color: Color(0xFFD9D9D9),
                    ),
                  ),
                ),
              ),
            ),

            //Main Body
            body: RefreshIndicator(
                color: Theme.of(context).colorScheme.secondary,
                onRefresh: _loadData,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 30.0, 8.0, 8.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                GFImageOverlay(
                                  image: AssetImage(
                                      'lib/assets/images/Bestday_img.png'),
                                  shape: BoxShape.circle,
                                  width: 36,
                                  height: 36,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Best of the Day',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        _getClampedFontSize(context, 0.05),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //Carousel
                        DefaultTextStyle(
                          style: const TextStyle(
                            fontFamily: 'Sora',
                          ),
                          child: CarouselSlider.builder(
                            itemCount: days.length,
                            itemBuilder: (context, index, realIndex) {
                              if (days.isEmpty) {
                                return const Center(
                                  child: Text('No moments available.'),
                                );
                              }
                              final moment = days[index];
                              bool isMainPhoto = realIndex == index;

                              return GestureDetector(
                                onTap: () => goFullScreenImage(
                                  context,
                                  moment.imageUrl,
                                  moment.dayName,
                                ),
                                onDoubleTap: () => _toggleFavorites(),
                                child: MyDay(
                                  moment: moment,
                                  isMainPhoto: isMainPhoto,
                                  toggleFavorites: _toggleFavorites,
                                ),
                              );
                            },
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                              height: MediaQuery.of(context).size.height * 0.4,
                              autoPlay: false,
                              viewportFraction: 0.7,
                              enableInfiniteScroll: false,
                              reverse: true,
                              scrollDirection: Axis.horizontal,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                  _currentDayId = days[index].dayId;
                                  _isInitialLoad = false;
                                });
                              },
                            ),
                          ),
                        ),



              //View Comment Icon
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // When comment icon is pressed, focus on the comment text field
                                    FocusScope.of(context)
                                        .requestFocus(_fieldComment);
                                  },
                                  icon: Icon(
                                    Icons.comment_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    size: 24,
                                  ),
                                ),
                                Text(
                                  'Comments',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontFamily: 'Sora',
                                    fontSize:
                                        _getClampedFontSize(context, 0.04),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //Comment Section
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 20, left: 20.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.28,
                              width: MediaQuery.of(context).size.width,
                              child: Scrollbar(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0,
                                      top: 8.0,
                                      right: 4.0,
                                      left: 4.0),
                                  child: comments[_currentDayId] == null ||
                                          comments[_currentDayId]!.isEmpty
                                      ? const Center(
                                          child: Text('No comments available.'),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true, // Add this line
                                          itemCount:
                                              comments[_currentDayId]!.length,
                                          itemBuilder: (context, index) {
                                            final comment =
                                                comments[_currentDayId]![index];
                                            return ListTile(
                                              leading: GFImageOverlay(
                                                image: Image.network(comment
                                                        .profilePictureUrl)
                                                    .image,
                                                shape: BoxShape.circle,
                                                height: 36,
                                                width: 36,
                                              ),
                                              title: Text(
                                                comment.content,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary,
                                                  fontFamily: 'Sora',
                                                  fontSize: _getClampedFontSize(
                                                      context, 0.04),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          //Comment Text Field
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                GFImageOverlay(
                                  image: userProfile == null ||
                                          userProfile.pictureUrl.isEmpty
                                      ? const AssetImage(
                                          'lib/assets/images/user_icon.png')
                                      : Image.network(userProfile.pictureUrl)
                                          .image,
                                  shape: BoxShape.circle,
                                  height: 50,
                                  width: 50,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: MyCommentTextField(
                                    focusNode: _fieldComment,
                                    controller: _commentController,
                                    hintText: ' Comment...',
                                    obscureText: false,
                                    onSubmitted: (value) {
                                      if (mounted) {
                                        _fieldComment.unfocus();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                IconButton(
                                  onPressed: _sendComment,
                                  icon: Icon(
                                    Icons.send,
                                    size: 35,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ),

                          //Bottom Padding
                          const SizedBox(height: 100),
                          Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context)
                                      .viewInsets
                                      .bottom)),
                          // Test Icons
                          // IconButton(
                          //   onPressed: _logout,
                          //   icon: const Icon(Icons.logout),
                          // ),
                          // IconButton(
                          //   onPressed: () => goSetup(context),
                          //   icon: const Icon(Icons.home),
                          // ),
                        ],
                      ),
                    ),
                    if (!_isKeyboardVisible)
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
                                          onTap: _currentDay != null
                                              ? () {}
                                              : () {
                                                  if (item['title'] ==
                                                      'Enter a day code') {
                                                    _showEnterDayCodeDialog(
                                                        context);
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
                )),
          ),
        ));
  }
}
