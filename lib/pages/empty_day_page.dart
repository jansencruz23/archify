import 'package:flutter/material.dart';

class EmptyDayPage extends StatelessWidget {
  const EmptyDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            const Text('Pssst... the room\'s waiting for you. Got the code?'),
      ),
    );
  }
}
