import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy',
          style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(right: 30.0, left: 40.0, top: 8.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            SizedBox(height: 16.0),
            Text(
              '1. Acceptance of Terms\n'
              'By accessing and using this app, you accept and agree to be bound by the terms and conditions set forth in this agreement.\n\n'
              '2. Changes to Terms\n'
              'We reserve the right to modify or revise these terms at any time. It is your responsibility to check this page periodically for updates.\n\n'
              '3. Use of the App\n'
              'You agree not to use this app for any unlawful or prohibited purpose.\n\n'
              '4. User Content\n'
              'You are responsible for any content you post, upload, or share within the app.\n\n'
              '5. Limitation of Liability\n'
              'We are not liable for any damages that may arise from the use of this app.\n\n'
              '6. Governing Law\n'
              'These terms are governed by the laws of your country.\n\n'
              '7. Contact\n'
              'For any questions regarding these terms, please contact us at support@archify.com.\n',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 32.0),
            Center(
              child: Text(
                'Last updated: [30.11.2024]',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
