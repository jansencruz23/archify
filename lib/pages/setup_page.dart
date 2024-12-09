import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/pages/setup_pages/setup_intro_page.dart';
import 'package:archify/pages/setup_pages/setup_name_page.dart';
import 'package:archify/pages/setup_pages/setup_profile_pic_page.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late final UserProvider _userProvider;

  late final TextEditingController _nameController;
  late final PageController _pageController;

  late int _currentIndex;
  late String _localPicturePath;

  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
    _localPicturePath = '';

    _nameController = TextEditingController();
    _pageController = PageController(initialPage: 0);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.toInt();
      });
    });
  }

  // Open image picker
  Future<void> onProfileTapped() async {
    final imagePath = await _userProvider.openImagePicker();
    setState(() {
      _localPicturePath = imagePath;
    });
  }

  // Upload profile picture to filebase
  Future<String> uploadProfilePicture() async {
    return await _userProvider.uploadProfilePicture(_localPicturePath);
  }

  Future<void> finishSetup() async {
    goDayGate(context);
    final pictureUrl = await uploadProfilePicture();
    await _userProvider.updateUserAfterSetup(
      name: _nameController.text,
      pictureUrl: pictureUrl,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                SetupIntroPage(),
                SetupNamePage(
                  nameController: _nameController,
                  userProvider: _userProvider,
                ),
                SetupProfilePicPage(onTap: onProfileTapped),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0, top: 0, bottom: 30),
            child: Column(
              children: [

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => buildDot(context, index)),
                  ),
                ),
                Container(
                  height: 60,
                  margin: const EdgeInsets.all(40),
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () async {
                      // Last page
                      if (_currentIndex == 2) {
                        await finishSetup();
                      } else {
                        // If may kasunod pa
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.bounceIn,
                        );
                        _currentIndex++;
                      }
                    },
                    child: Text(_currentIndex == 2 ? 'Continue' : 'Next', style: TextStyle(fontFamily: 'Sora'),),
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }

  // Yung ... na red
  AnimatedContainer buildDot(BuildContext context, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 10,
      width: _currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
