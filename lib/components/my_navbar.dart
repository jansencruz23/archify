import 'package:flutter/material.dart';

class MyNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool showVerticalBar;

  const MyNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.showVerticalBar,
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

  Widget _buildNavIcon(String iconPath, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            height: navIconSize,
            width: navIconSize,
          ),
          if (selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 8,
              width: 8,
              decoration: BoxDecoration(
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
      onTap: () => onItemTapped(2),
      child: Transform.translate(
        offset: const Offset(0, -15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
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
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Color(0xFFD2691E),
                  size: 28,
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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showVerticalBar = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showVerticalBar = index == 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selected Index: $_selectedIndex'),
            SizedBox(height: 20),
            MyNavbar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              showVerticalBar: _showVerticalBar,
            ),
            if (_showVerticalBar)
              Container(
                width: 10,
                height: 80,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
