import 'package:flutter/material.dart';

class SetupIntroPage extends StatelessWidget {
  const SetupIntroPage({super.key});
  //For Responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Ang min and max nyaa
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            SizedBox(height: 100),
             Text('Let\'s set you up.', style: TextStyle(
          fontFamily: 'Sora',
          color: Theme.of(context).colorScheme.inversePrimary,
          fontSize: _getClampedFontSize(context, 0.5),
        ),
             ),
            Padding(
              padding: const EdgeInsets.only(right: 0, top: 70, bottom: 0),
              child: Image.asset('lib/assets/images/SetUp-Icon.png'),
            )
          ],
        ),
      ),
    );
  }
}
