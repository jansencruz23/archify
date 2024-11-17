import 'package:archify/models/day.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/base_provider.dart';
import 'package:archify/services/database/day/day_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DayProvider extends BaseProvider {
  final _dayService = DayService();
  final _authService = AuthService();

  Day? _day;
  Day? get day => _day;

  Future<void> loadDay(String dayId) async {
    final day = await _dayService.getDayFromFirebase(dayId);
    if (day == null) {
      return;
    }

    _day = day;
    notifyListeners();
  }

  Future<String> createDay({
    required String name,
    required String description,
    required int maxParticipants,
    required TimeOfDay votingDeadline,
  }) async {
    final now = DateTime.now();
    final uuid = Uuid();

    final day = Day(
      id: '',
      hostId: _authService.getCurrentUid(),
      name: name,
      description: description,
      maxParticipants: maxParticipants,
      votingDeadline: DateTime(now.year, now.month, now.day,
          votingDeadline.hour, votingDeadline.minute),
      code: uuid.v4().substring(0, 5),
      createdAt: now,
    );

    return await _dayService.createDayInFirebase(day);
  }

  Future<void> startDay(String dayId, String nickname) async {
    await _dayService.startDayInFirebase(dayId, nickname);
  }

  Future<void> deleteDay(String day) async {
    // Delete a day from the database
  }

  Future<void> updateDay(String day) async {
    // Update a day in the database
  }
}
