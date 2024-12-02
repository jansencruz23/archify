import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/pages/edit_profile_page.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late final UserProvider _userProvider;
  int _selectedIndex = 3;
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
      if (index == 2) {
        if (_showVerticalBar) {
          _animationController.reverse();
        } else {
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

    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _loadUserProfile();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
  }

  Future<void> _loadUserProfile() async {
    await _userProvider.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<UserProvider>(context);
    final userProfile = listeningProvider.userProfile;

    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(180),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: AppBar(
                leadingWidth: 120,
                toolbarHeight: 75,
                titleSpacing: 0,
                leading: MyProfilePicture(
                  height: 150,
                  width: 120,
                  onProfileTapped: () {},
                  hasBorder: true,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile == null ? 'Loading' : userProfile.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      userProfile == null ? 'Loading' : userProfile.bio,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(30),
                  child: MyButton(
                    text: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
                    },
                    padding: 8,
                  ),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
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
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 30,
                                color: Colors.white,
                              ),
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
                                        _showEnterDayCodeDialog(
                                            context);
                                      } else if (item['title'] ==
                                          'Create a day') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => DaySettingsPage()),
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
            ],
          ),
        ),
      );
    });
  }
}
