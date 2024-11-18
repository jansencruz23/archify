import 'package:archify/models/day.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/day/day_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DayProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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
      status: true,
    );

    return await _dayService.createDayInFirebase(day);
  }

  Future<void> startDay(String dayCode, String nickname) async {
    await _dayService.startDayInFirebase(dayCode, nickname);
  }

  Future<bool> isDayExistingAndActive(String dayCode) async {
    return await _dayService.isDayExistingAndActiveInFirebase(dayCode);
  }

  Future<void> deleteDay(String day) async {
    // Delete a day from the database
  }

  Future<void> updateDay(String day) async {
    // Update a day in the database
  }
}
