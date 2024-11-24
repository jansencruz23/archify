import 'package:flutter/material.dart';

class MyNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool showVerticalBar;
  final bool isRotated;
  final Function toggleRotation;

  const MyNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.showVerticalBar,
    required this.isRotated,
    required this.toggleRotation,
  }) : super(key: key);

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
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: navIconSize,
            height: navIconSize,
          ),
          if (selectedIndex == index)
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

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.wb_sunny, 'title': 'Enter a day code'},
    {'icon': Icons.qr_code_scanner, 'title': 'Scan QR code'},
    {'icon': Icons.add_circle_outline, 'title': 'Create a day'},
    {'icon': Icons.settings, 'title': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut));
  }

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
            cursorColor: Colors.white, // Cursor remains white
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Sora',
                                    ),
                                  ),
                                  tileColor: _hoveredIndex == index
                                      ? const Color(0xFFF2776B)
                                      : Colors.transparent,
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
