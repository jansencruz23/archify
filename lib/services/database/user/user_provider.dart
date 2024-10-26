import 'package:archify/models/user_profile.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/base_provider.dart';
import 'package:archify/services/database/user/user_service.dart';

class UserProvider extends BaseProvider {
  final _authService = AuthService();
  final _userService = UserService();

  // Gets current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _authService.getCurrentUid();
    return await _userService.getUserFromFirebase(uid);
  }

  // Get a user's profile by their id
  Future<UserProfile?> getUserProfile(String uid) async {
    return await _userService.getUserFromFirebase(uid);
  }

  // Save user after registering
  Future<void> saveUser(String email) async {
    await _userService.saveUserInFirebase(email);
  }

  // Update user is not new
  Future<void> updateUserNotNew() async {
    await _userService.updateUserNotNewInFirebase();
  }
}
