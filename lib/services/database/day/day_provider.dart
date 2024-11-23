import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/day/day_service.dart';
import 'package:archify/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _storageService = StorageService();

  Day? _day;
  Day? get day => _day;

  List<Moment>? _moments;
  List<Moment>? get moments => _moments;

  Future<void> loadDay(String dayId) async {
    final day = await _dayService.getDayFromFirebase(dayId);
    if (day == null) {
      return;
    }

    _day = day;
    notifyListeners();
  }

  Future<void> loadDayByCode(String dayCode) async {
    final day = await _dayService.getDayByCodeFromFirebase(dayCode);
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

  // Open gallery and get the profile picture path
  Future<void> openImagePicker({
    required bool isCameraSource,
    required String dayCode,
  }) async {
    final source = isCameraSource ? ImageSource.camera : ImageSource.gallery;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) {
      return;
    }

    final imageUrl = await uploadImage(image.path);
    await _dayService.sendImage(imageUrl, dayCode);
    await loadMoments(dayCode);

    notifyListeners();
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(String path) async {
    return await _storageService.uploadDayImage(path);
  }

  Future<void> loadMoments(String dayCode) async {
    final moments = await _dayService.getMomentsFromFirebase(dayCode);
    if (moments.isEmpty) {
      _moments = [];
    }

    _moments = moments;
    notifyListeners();
  }
}
