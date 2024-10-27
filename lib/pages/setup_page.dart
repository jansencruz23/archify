import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/pages/setup_pages/setup_intro_page.dart';
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
  late int _currentIndex;
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
    _controller = PageController(initialPage: 0);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _controller.addListener(() {
      setState(() {
        _currentIndex = _controller.page!.toInt();
      });
    });
  }

  // Update user so setup page will not be displaying again
  Future<void> updateUserNotNew() async {
    await _userProvider.updateUserNotNew();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [SetupIntroPage(), SetupIntroPage(), SetupIntroPage()],
            ),
          ),
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
                  goRootPage(context);
                  await updateUserNotNew();
                } else {
                  // If may kasunod pa
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.bounceIn,
                  );
                  _currentIndex++;
                }
              },
              child: Text(_currentIndex == 2 ? 'Continue' : 'Next'),
            ),
          )
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
