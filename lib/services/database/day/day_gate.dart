// To determine if day space if joineddays has the same date as today or go to empty day page
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/pages/day_code_page.dart';
import 'package:archify/pages/day_space_page.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DayGate extends StatefulWidget {
  const DayGate({super.key});

  @override
  State<DayGate> createState() => _DayGateState();
}

class _DayGateState extends State<DayGate> {
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<String?> _checkJoinedDay() async {
    final code = await _userProvider.getJoinedDayCodeToday();
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _checkJoinedDay(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasData) {
              return DaySpacePage(dayCode: snapshot.data.toString());
            } else {
              return EmptyDayPage();
            }
          }),
    );
  }
}
