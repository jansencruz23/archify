import 'package:flutter/material.dart';

class DayExpiredPage extends StatefulWidget {
  const DayExpiredPage({super.key});

  @override
  State<DayExpiredPage> createState() => _DayExpiredPageState();
}

class _DayExpiredPageState extends State<DayExpiredPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child:
              const Text('The photo battle is over—see the winning moment!')),
    );
  }
}
