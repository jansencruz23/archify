import 'dart:async';
import 'package:archify/helpers/font_helper.dart';
import 'package:archify/services/database/day/day_gate.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/pages/day_settings_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../components/my_mobile_scanner_overlay.dart';
import '../helpers/navigate_pages.dart';
import '../models/day.dart';
import '../services/database/day/day_provider.dart';
import 'package:provider/provider.dart';
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/settings_page.dart';

class NoMomentUploadedPage extends StatefulWidget {
  final Day? day;
  final DateTime? votingDeadline;
  final void Function() imageUploadClicked;
  final void Function() cameraUploadClicked;
  final void Function() settingsClicked;

  const NoMomentUploadedPage({
    super.key,
    required this.imageUploadClicked,
    required this.cameraUploadClicked,
    required this.settingsClicked,
    required this.votingDeadline,
    required this.day,
  });

  @override
  State<NoMomentUploadedPage> createState() => _NoMomentUploadedPageState();
}

class _NoMomentUploadedPageState extends State<NoMomentUploadedPage>
    with TickerProviderStateMixin {
  late Day? day;
  late Day? _currentDay;
  int _selectedIndex = 1;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late final UserProvider _userProvider;
  late final DayProvider _dayProvider;
  late Timer _timer = Timer.periodic(Duration.zero, (timer) {});
  late Duration _remainingTime = Duration.zero;

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

            var tween = Tween(begin: startOffset, end: end)
                .chain(CurveTween(curve: curve));

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
          customRoute(
              HomePage(), Offset(-1.0, 0.0)), // navigate from left to right
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
          customRoute(
              ProfilePage(), Offset(1.0, 0.0)), // navigate from right to left
        );
      } else if (index == 4) {
        Navigator.pushReplacement(
          context,
          customRoute(
              SettingsPage(), Offset(1.0, 0.0)), // navigate from right to left
        );
      }
    });
  }

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
    });
  }

  void _showDayCode(String code, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "QR Code",
            style: TextStyle(
              fontFamily: 'Sora',
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(height: 10),
                  Text(
                    code,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Close",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: 'Sora',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  bool? _isHost;

  Future<void> _checkIsHost() async {
    if (day != null) {
      final result = await _dayProvider.isHost(day!.id);
      if (mounted) {
        setState(() {
          _isHost = result;
        });
      }
    }
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
    day = widget.day;
    _dayProvider = Provider.of<DayProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (day != null) {
        _remainingTime = day!.votingDeadline.difference(DateTime.now());
      }

      _userProvider.updateCurrentDay();
      _checkIsHost();
    });
  }

  void _startCountdown() {
    if (widget.votingDeadline != null) {
      _remainingTime = widget.votingDeadline!.difference(DateTime.now());
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (widget.votingDeadline == null) return;
        final newRemainingTime =
            widget.votingDeadline!.difference(DateTime.now());
        if (newRemainingTime <= Duration.zero ||
            _remainingTime <= Duration.zero ||
            !day!.status) {
          timer.cancel();
          setState(() {
            _remainingTime = Duration.zero;
            goDayGate(context);
          });
        } else {
          setState(() {
            _remainingTime = newRemainingTime;
          });
        }
      });
    } else {
      _remainingTime = Duration.zero;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (duration.inMinutes == 0) {
      return '$seconds secs';
    } else if (hours == 0) {
      return '$minutes mins';
    } else {
      return '${hours}hr ${minutes}mins';
    }
  }

  void _showCameraOrGalleryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'Sora',
            color: Color(0xFF333333),
            fontSize: getClampedFontSize(context, 0.045),
            fontWeight: FontWeight.w600,
          ),
          child: Text('Choose an option'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt_rounded, color: Color(0xFF333333)),
                SizedBox(width: 8), // Space between the icon and text
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.cameraUploadClicked();
                  },
                  child: Text(
                    'Take Photo',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // Space between the two options
            Row(
              children: [
                Icon(Icons.photo_rounded, color: Color(0xFF333333)),
                SizedBox(width: 8), // Space between the icon and text
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.imageUploadClicked();
                  },
                  child: Text(
                    'Upload Photo',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final userListeningProvider = Provider.of<UserProvider>(context);
    _currentDay = userListeningProvider.currentDay;
    day = listeningProvider.day;
    if (day != null) {
      _remainingTime = day!.votingDeadline.difference(DateTime.now());
      _checkIsHost();
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 15, bottom: 10),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 0, top: 0, bottom: 0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: GestureDetector(
                              onTap: () => _showDayCode(
                                day?.code ?? '',
                                day?.name ?? '',
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'DAY CODE: ${day?.code ?? ''}',
                                  style: TextStyle(
                                    fontSize: getClampedFontSize(context, 0.0),
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 0, top: 0, bottom: 0),
                          child: _isHost == null
                              ? const SizedBox()
                              : _isHost!
                                  ? IconButton(
                                      onPressed: widget.settingsClicked,
                                      icon: Image.asset(
                                        'lib/assets/images/edit_icon.png',
                                        width: 26,
                                        height: 26,
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: widget.settingsClicked,
                                      icon: Image.asset(
                                        'lib/assets/images/leave_icon.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Oops, no peeking! \nYou haven\'t uploaded a moment yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: getClampedFontSize(context, 0.05),
                        fontFamily: 'Sora',
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    MyButton(
                      text: 'Upload your masterpiece',
                      onTap: () => _showCameraOrGalleryDialog(context),
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
                  updateCurrentDay: _loadCurrentDay),
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
