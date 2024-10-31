import 'dart:math';

import 'package:archify/models/user_profile.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/base_provider.dart';
import 'package:archify/services/database/user/user_service.dart';
import 'package:archify/services/storage/storage_service.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends BaseProvider {
  final _authService = AuthService();
  final _userService = UserService();
  final _storageService = StorageService();

// IDISPLAY
  late String _picturePath = '';
  String get picturePath => _picturePath;

  // Gets current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _authService.getCurrentUid();
    var user = await _userService.getUserFromFirebase(uid);

    if (user == null) {
      return null;
    }

    _picturePath = user.pictureUrl;
    notifyListeners();
    return user;
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
  Future<void> updateUserAfterSetup(
      {required String name, required String pictureUrl}) async {
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
    _picturePath = await _storageService.uploadImage(path);
    return _picturePath;
  }
}
