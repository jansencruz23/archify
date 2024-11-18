import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  bool showVerticalBar = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        if (showVerticalBar) {
          _animationController.reverse();
        } else {
          _animationController.duration = Duration(milliseconds: 500);
          _animationController.forward();
        }
        showVerticalBar = !showVerticalBar;
      } else {
        if (showVerticalBar) {
          _animationController.reverse();
          showVerticalBar = false;
        }
      }
      selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Navbar Example'),
      ),
      body: Stack(
        children: [
          Center(
            child: Text('Content here'),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MyNavbar(
              selectedIndex: selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
          if (showVerticalBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: MediaQuery.of(context).size.height * 0.5 + 80,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_down, size: 30),
                          onPressed: () {
                            setState(() {
                              _animationController.reverse();
                              showVerticalBar = false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.circle, color: Colors.blue),
                              title: Text('Item ${index + 1}'),
                              onTap: () {},
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

class MyNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MyNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
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
            _buildNavIcon(Icons.home, 0),
            _buildNavIcon(Icons.favorite, 1),
            _buildElevatedNavIcon(),
            _buildNavIcon(Icons.person, 3),
            _buildNavIcon(Icons.settings, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: navIconSize,
            color: isSelected ? Color(0xFFFF6F61) : Colors.black,
          ),
          if (isSelected)
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
