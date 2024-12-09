import 'dart:async';

import 'package:archify/components/my_input_alert_box.dart';
import 'package:archify/components/my_mobile_scanner_overlay.dart';
import 'package:archify/components/my_moment_tile.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/components/my_navbar.dart';
import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/pages/no_moment_uploaded_page.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:archify/components/my_nickname_and_avatar_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:archify/pages/home_page.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/pages/profile_page.dart';
import 'package:archify/pages/settings_page.dart';
import 'package:archify/pages/day_settings_page.dart';

class DaySpacePage extends StatefulWidget {
  final String dayCode;

  const DaySpacePage({super.key, required this.dayCode});

  @override
  State<DaySpacePage> createState() => _DaySpacePageState();
}

class _DaySpacePageState extends State<DaySpacePage>
    with TickerProviderStateMixin {
  late final TextEditingController _avatarController;
  late final TextEditingController _nicknameController;
  late final FocusNode _nicknameFocusNode;
  late final DayProvider _dayProvider;
  late final UserProvider _userProvider;
  late Day? day;
  late Day? _currentDay;
  late String _dayCode;
  String qrCode = '';

  int _selectedIndex = 1;
  bool _showVerticalBar = false;
  bool _isRotated = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Timer _timer = Timer.periodic(Duration.zero, (timer) {});
  late Duration _remainingTime = Duration.zero;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.wb_sunny, 'title': 'Enter a day code'},
    {'icon': Icons.qr_code_scanner, 'title': 'Scan QR code'},
    {'icon': Icons.add_circle_outline, 'title': 'Create a day'},
  ];

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
    _dayCode = widget.dayCode;

    _avatarController = TextEditingController();
    _nicknameController = TextEditingController();
    _nicknameFocusNode = FocusNode();
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
      _isParticipant().then((isParticipant) {
        if (!isParticipant) _showNicknameAndAvatarDialog();
      });
      _checkIsHost();
      _loadDay();
      _startCountdown();
    });
  }

  void _startCountdown() {
    if (day?.votingDeadline != null) {
      _remainingTime = day!.votingDeadline.difference(DateTime.now());
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (day == null) {
          timer.cancel();
          return;
        }
        final newRemainingTime = day!.votingDeadline.difference(DateTime.now());
        if (newRemainingTime <= Duration.zero) {
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

  Future<bool> _isParticipant() async {
    return await _dayProvider.isParticipant(_dayCode);
  }

  void _showImageDialog(Moment moment, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: InteractiveViewer(
                  child: MyMomentTile(
                    moment: moment,
                    index: index,
                    toggleVote: _toggleVote,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
    _dayCode = '';
  }

  void _showNicknameAndAvatarDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  'Who are you today?',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Sora',
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              content: Container(
                height: 410,
                width: double.infinity,
                child: MyNicknameAndAvatarDialog(
                  nicknameController: _nicknameController,
                  avatarController: _avatarController,
                  onSubmit: _startDay,
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

  Future<void> _loadDay() async {
    await _dayProvider.loadDayByCode(_dayCode);
    await _dayProvider.loadMoments(_dayCode);
    await _dayProvider.loadHasUploaded(_dayCode);
  }

  Future<void> _startDay() async {
    await _dayProvider.startDay(
      _dayCode,
      _nicknameController.text,
      _avatarController.text,
    );
  }

  Future<void> _loadCurrentDay() async {
    await _userProvider.updateCurrentDay();
  }

  Future<void> _imageUploadClicked() async {
    await _dayProvider.openImagePicker(
      isCameraSource: false,
      dayCode: _dayCode,
    );
  }

  Future<void> _cameraUploadClicked() async {
    await _dayProvider.openImagePicker(
      isCameraSource: true,
      dayCode: _dayCode,
    );
  }

  Future<void> _showSettings() async {
    if (day == null) return;

    final isHost = await _dayProvider.isHost(day!.id);

    if (isHost && mounted) {
      goEditSettings(context, day!);
    } else {
      _showParticipantSettings();
    }
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
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.inversePrimary),
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
                  color: Theme.of(context).colorScheme.inversePrimary,
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

  void _showParticipantSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave the Day?'),
        content: Text('Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              goRootPage(context);
              await _leaveDay();
            },
            child: Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveDay() async {
    await _dayProvider.leaveDay(day!.id);
  }

  Future<void> _toggleVote(String momentId) async {
    await _dayProvider.toggleVote(_dayCode, momentId);
  }

  //Font responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final userListeningProvider = Provider.of<UserProvider>(context);
    _currentDay = userListeningProvider.currentDay;
    day = listeningProvider.day;
    final moments = listeningProvider.moments;
    final hasUploaded = listeningProvider.hasUploaded;
    listeningProvider.listenToMoments(_dayCode);
    if (day != null) {
      _remainingTime = day!.votingDeadline.difference(DateTime.now());
      _checkIsHost();
    }

    return Scaffold(
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
                    fontSize: _getClampedFontSize(context, 0.03),
                    fontFamily: 'Sora',
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Positioned(
                  bottom: -6,
                  left: 0,
                  child: Text(
                    'Pick the best shot!',
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.05),
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
            preferredSize: const Size.fromHeight(5),
            child: Divider(
              height: 5,
              color: Color(0xFFD9D9D9),
            ),
          ),
        ),
      ),
      body: hasUploaded
          ? Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Center(
                      child: Column(
                        children: [
                          // Day Code Container
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, top: 20, bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                                          fontSize: _getClampedFontSize(
                                              context, 0.03),
                                          fontFamily: 'Sora',
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, top: 20, bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      day?.votingDeadline == null
                                          ? 'DEADLINE: N/A'
                                          : 'DEADLINE: ${_formatDuration(_remainingTime)}',
                                      style: TextStyle(
                                        fontSize:
                                            _getClampedFontSize(context, 0.03),
                                        fontFamily: 'Sora',
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 8, top: 20, bottom: 10),
                                child: _isHost == null
                                    ? const SizedBox()
                                    : _isHost!
                                        ? IconButton(
                                            onPressed: _showSettings,
                                            icon: Image.asset(
                                              'lib/assets/images/edit_icon.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          )
                                        : IconButton(
                                            onPressed: _showSettings,
                                            icon: Image.asset(
                                              'lib/assets/images/leave_icon.png',
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                              ),
                            ],
                          ),
                          // Moments Grid
                          Expanded(
                            child: MasonryGridView.builder(
                              gridDelegate:
                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                              itemCount: moments?.length ?? 0,
                              itemBuilder: (context, index) {
                                final moment = moments![index];
                                return MyMomentTile(
                                  moment: moment,
                                  onTap: _showImageDialog,
                                  index: index,
                                  toggleVote: _toggleVote,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
                    updateCurrentDay: _loadCurrentDay,
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
            )
          : NoMomentUploadedPage(
              imageUploadClicked: _imageUploadClicked,
              cameraUploadClicked: _cameraUploadClicked,
              settingsClicked: _showSettings,
              votingDeadline: day?.votingDeadline,
              day: day ?? null,
            ),
    );
  }
}
