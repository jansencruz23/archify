import 'package:archify/helpers/font_helper.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/models/day.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/components/my_profile_picture.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/day_code_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/settings_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:archify/components/my_mobile_scanner_overlay.dart';

class LoadingDayPage extends StatefulWidget {
  const LoadingDayPage({super.key}); //try scanner

  @override
  State<LoadingDayPage> createState() => _LoadingDayPage();
}

class _LoadingDayPage extends State<LoadingDayPage>
    with TickerProviderStateMixin {
  late final UserProvider _userProvider;
  late final DayProvider _dayProvider;
  late Day? _currentDay;
  int _selectedIndex = 1;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  //Try lang qr scanner
  String qrCode = '';

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.wb_sunny, 'title': 'Enter a day code'},
    {'icon': Icons.qr_code_scanner, 'title': 'Scan QR code'},
    {'icon': Icons.add_circle_outline, 'title': 'Create a day'},
  ];

  //try lang qr scanner
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
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

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _dayProvider = Provider.of<DayProvider>(context, listen: false);
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _userListeningProvider = Provider.of<UserProvider>(context);
    _currentDay = _userListeningProvider.currentDay;

    return SafeArea(
      child: Scaffold(
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
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 2,
                color: Color(0xFFD9D9D9),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [],
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
  }
}

// class QRScannerScreen extends StatelessWidget {
//   final Function(String) onScan;
//
//   const QRScannerScreen({required this.onScan, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan QR Code')),
//       body: Stack(
//         children: [
//           MobileScanner(
//             onDetect: (capture) {
//               final List<Barcode> barcodes = capture.barcodes;
//               for (final barcode in barcodes) {
//                 if (barcode.rawValue != null) {
//                   onScan(barcode.rawValue!); // Pass the scanned value back
//                   break;
//                 }
//               }
//             },
//           ),
//           MobileScannerOverlay(
//             overlayColor: Colors.black.withOpacity(0.5), // Adjust the opacity for the overlay
//             borderWidth: 2.0, // Width of the border around the scanning area
//             borderColor: Colors.green, // Color of the border
//             borderRadius: BorderRadius.circular(12), // Rounded corners for the border
//             borderLength: 50, // Length of the border
//             child: Container(), // Optional child widget to display above the overlay
//           ),
//         ],
//       ),
//     );
//   }
// }
