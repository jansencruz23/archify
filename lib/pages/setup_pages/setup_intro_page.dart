import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SetupIntroPage extends StatelessWidget {
  const SetupIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            const Text('Let\s set you up.'),
          ],
        ),
      ),
    );
  }
}
