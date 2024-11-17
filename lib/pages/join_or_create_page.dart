import 'package:archify/components/my_button.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:flutter/material.dart';

class JoinOrCreatePage extends StatelessWidget {
  const JoinOrCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButton(text: 'Host a Day', onTap: () => goDaySettings(context)),
              MyButton(text: 'Join', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
