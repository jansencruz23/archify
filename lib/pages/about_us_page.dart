import 'package:archify/helpers/font_helper.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(
              fontFamily: 'Sora',
              fontSize: getClampedFontSize(context, 0.04),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(right: 30.0, left: 40.0, top: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Story',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: getClampedFontSize(context, 0.03),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            SizedBox(height: 16.0),
            Text(
              'Archify, our app was created with the mission to foster deeper, more meaningful connections between friends and loved ones by creating an interactive platform that makes sharing moments more personal and engaging, while encouraging friendly competition.\n\n'
              'We believe that the only way to fight technology that disrupt relationships is through another technological tool. Our team is passionate about creating technologies to benefit our social lives, and we are dedicated to providing you with the best experience possible.\n\n'
              'Thank you for being part of our journey and helping us grow!',
              style: TextStyle(
                fontFamily: 'Sora',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 32.0),
            Text(
              'Meet the Team',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: getClampedFontSize(context, 0.03),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Member 1
                Row(
                  children: [
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        '1. Jansen Cruz - (Developer)\n'
                        'This dev is like the Sherlock Holmes of the team. He finds problems so fast, it’s almost scary.',
                        style: TextStyle(
                            fontFamily: 'Sora',
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // Team Member 2
                Row(
                  children: [
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        '2. Aljunalei Alfonso - (Developer)\n'
                        'This dev will spend hours making sure that button looks just right and that every pixel is perfectly aligned.',
                        style: TextStyle(
                            fontFamily: 'Sora',
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // Team Member 3
                Row(
                  children: [
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        '3. Jamaica Salem - (Developer)\n'
                        'This dev can crank out features faster than anyone else, but they’re the person who writes code like they’re trying to win a sprint race.',
                        style: TextStyle(
                            fontFamily: 'Sora',
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
