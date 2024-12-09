import 'package:archify/helpers/font_helper.dart';
import 'package:flutter/material.dart';

class SetupIntroPage extends StatelessWidget {
  const SetupIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Text(
              'Let\'s set you up.',
              style: TextStyle(
                fontFamily: 'Sora',
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: getClampedFontSize(context, 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
