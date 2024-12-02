import 'dart:math';
import 'package:archify/models/moment.dart';
import 'package:archify/models/user_profile.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/database/day/day_service.dart';
import 'package:archify/services/database/user/user_service.dart';
import 'package:archify/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  final _authService = AuthService();
  final _userService = UserService();
  final _dayService = DayService();
  final _storageService = StorageService();

  // Properties to call in the UI
  late String _picturePath = '';
  String get picturePath => _picturePath;

  late UserProfile? _userProfile = UserProfile(
      uid: '',
      name: '',
      email: '',
      username: '',
      bio: '',
      pictureUrl: '',
      isNew: false);
  UserProfile? get userProfile => _userProfile;

  late List<Moment> _moments = [];
  List<Moment> get moments => _moments;

  late List<String> _favoriteDaysIds = [];
  List<String> get favoriteDaysIds => _favoriteDaysIds;

  // Gets current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _authService.getCurrentUid();
    return await _userService.getUserFromFirebase(uid);
  }

  Future<void> loadUserProfile() async {
    setLoading(true);
    final user = await getCurrentUserProfile();
    if (user == null) return;

    _userProfile = user;
    _picturePath = user.pictureUrl;

    setLoading(false);
    notifyListeners();
  }

  Future<void> loadUserMoments() async {
    final user = await getCurrentUserProfile();
    if (user == null) return;

    _moments = await _userService.getUserMomentsFromFirebase();
    _favoriteDaysIds = user.favoriteDays.map((day) => day.dayId).toList();

    notifyListeners();
  }

  // Get a user's profile by their id
  Future<UserProfile?> getUserProfile(String uid) async {
    return await _userService.getUserFromFirebase(uid);
  }

  Future<UserProfile?> getUserProfileByEmail(String email) async {
    return await _userService.getUserByEmailFromFirebase(email);
  }

  // Save user after registering
  Future<void> saveUser(String email) async {
    await _userService.saveUserInFirebase(email);
  }

  // Update user is not new
  Future<void> updateUserAfterSetup({
    required String name,
    required String pictureUrl,
  }) async {
    await _userService.updateUserAfterSetupInFirebase(
      name: name != '' ? name : 'Anon',
      pictureUrl: pictureUrl,
    );
  }

  // Gets 3 random name based from username
  Future<List<String>> getRandomNames() async {
    final user = await getCurrentUserProfile();
    final username = user!.username;

    List<String> names = [];

    names.add(username);
    names.add(randomNameGenerator(username));
    names.add(randomNameGenerator(username));

    return names;
  }

  // Generates a random name based on the given username
  String randomNameGenerator(String username) {
    final random = Random();
    final randomNumber = random.nextInt(1000);
    return '$username${randomNumber.toString()}';
  }

  // Open gallery and get the profile picture path
  Future<String> openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    _picturePath = image == null ? '' : image.path;

    notifyListeners();
    return _picturePath;
  }

  // Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(String path) async {
    _picturePath = await _storageService.uploadProfilePicture(path);
    return _picturePath;
  }

  Future<String?> getJoinedDayCodeToday() async {
    final dayId = await _userService.getJoinedDayIdToday();
    if (dayId == null) return null;

    final dayCode = await _dayService.getDayFromFirebase(dayId);
    if (dayCode == null) return null;

    return dayCode.code;
  }

  Future<void> toggleFavorites(String dayId) async {
    if (_favoriteDaysIds.contains(dayId)) {
      _favoriteDaysIds.remove(dayId);
    } else {
      _favoriteDaysIds.add(dayId);
    }
    await _userService.addToFavoritesInFirebase(dayId);

    notifyListeners();
  }

  Future<void> updateUserProfile({
    required String name,
    required String bio,
    required String imagePath,
  }) async {
    if (_userProfile == null) return;

    final pictureUrl = await uploadProfilePicture(imagePath);
    await _userService.updateUserProfileInFirebase(name, bio, pictureUrl);

    _userProfile = _userProfile!.copyWith(
      name: name,
      bio: bio,
      pictureUrl: pictureUrl,
    );
    notifyListeners();
  }
}
