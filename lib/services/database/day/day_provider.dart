import 'package:archify/models/day.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/day/day_service.dart';
import 'package:flutter/material.dart';

class DayProvider extends ChangeNotifier {
  final _dayService = DayService();
  final _authService = AuthService();

  Future<void> getDays() async {
    // Get all days from the database
  }

  Future<void> createDay({
    required String name,
    required String description,
    required int maxParticipants,
    required TimeOfDay votingDeadline,
  }) async {
    final now = DateTime.now();

    final day = Day(
      id: '',
      hostId: _authService.getCurrentUid(),
      name: name,
      description: description,
      maxParticipants: maxParticipants,
      votingDeadline: DateTime(now.year, now.month, now.day,
          votingDeadline.hour, votingDeadline.minute),
      code: '',
    );

    await _dayService.createDayInFirebase(day);
  }

  Future<void> deleteDay(String day) async {
    // Delete a day from the database
  }

  Future<void> updateDay(String day) async {
    // Update a day in the database
  }

  Future<void> getDay(String day) async {
    // Get a day from the database
  }
}
