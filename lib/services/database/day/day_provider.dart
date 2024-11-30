import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/day/day_service.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/services/database/user/user_service.dart';
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
  final _userService = UserService();
  late UserProvider _userProvider;
  final _authService = AuthService();
  final _storageService = StorageService();

  Day? _day;
  Day? get day => _day;

  List<Moment>? _moments;
  List<Moment>? get moments => _moments;

  bool? _hasUploaded;

  void update(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  bool get hasUploaded => _hasUploaded ?? false;

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
    final now = DateTime.now().toUtc().add(Duration(hours: 8));
    final deadline = DateTime(now.year, now.month, now.day,
        (votingDeadline.hour - 8), votingDeadline.minute);
    final uuid = Uuid();
    final uid = _authService.getCurrentUid();

    final day = Day(
      id: '',
      hostId: uid,
      name: name,
      description: description,
      maxParticipants: maxParticipants,
      votingDeadline: deadline,
      code: uuid.v4().substring(0, 5),
      createdAt: now,
      status: true,
    );

    final dayId = await _dayService.createDayInFirebase(day);
    await _userService.addDayToUserProfile(dayId, uid);

    return dayId;
  }

  Future<void> startDay(String dayCode, String nickname) async {
    final dayId = await _dayService.getDayIdFromFirebase(dayCode);
    _userService.addDayToUserProfile(dayId, _authService.getCurrentUid());

    await _dayService.startDayInFirebase(dayCode, nickname);
  }

  Future<bool> isDayExistingAndActive(String dayCode) async {
    return await _dayService.isDayExistingAndActiveInFirebase(dayCode);
  }

  Future<bool> isRoomFull(String dayCode) async {
    return await _dayService.isRoomFull(dayCode);
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
    await _dayService.sendImageToFirebase(imageUrl, dayCode);
    await loadMoments(dayCode);
    await loadHasUploaded(dayCode);

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

  Future<void> likeImage(String dayCode, String momentId) async {
    await _dayService.likeImageInFirebase(dayCode, momentId);
  }

  Future<bool> isParticipant(String dayCode) async {
    return await _dayService.isParticipant(dayCode);
  }

  Future<void> loadHasUploaded(String dayCode) async {
    _hasUploaded = await _dayService.hasParticipantUploaded(dayCode);
    notifyListeners();
  }

  Future<bool> hasVotingDeadlineExpired(String dayCode) async {
    final expired = await _dayService.hasVotingDeadlineExpired(dayCode);
    _userProvider.loadUserMoments();
    notifyListeners();
    return expired;
  }

  Future<void> sendComment(String comment, String dayId) async {
    final userMoments = _userProvider.moments;
    final momentExists = userMoments.any((moment) => moment.dayId == dayId);
    if (!momentExists) return;

    await _dayService.sendCommentToFirebase(comment, dayId);
    _userProvider.loadUserMoments();
    notifyListeners();
  }
}
