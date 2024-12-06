import 'package:archify/pages/day_expired_page.dart';
import 'package:archify/pages/day_space_page.dart';
import 'package:archify/pages/empty_day_page.dart';
import 'package:archify/services/database/day/day_provider.dart';
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
  late final DayProvider _dayProvider;
  late String? code;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _dayProvider = Provider.of<DayProvider>(context, listen: false);
  }

  Future<String?> _checkJoinedDay() async {
    code = await _userProvider.getJoinedDayCodeToday();
    return code;
  }

  Future<bool> _hasVotingDeadlineExpired() async {
    return await _dayProvider.hasVotingDeadlineExpired(code!);
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
            return FutureBuilder(
              future: _hasVotingDeadlineExpired(),
              builder: (context, votingSnapshot) {
                if (votingSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (votingSnapshot.hasData &&
                    votingSnapshot.data == true) {
                  return DayExpiredPage();
                } else {
                  return DaySpacePage(dayCode: snapshot.data.toString());
                }
              },
            );
          } else {
            return EmptyDayPage();
          }
        },
      ),
    );
  }
}
