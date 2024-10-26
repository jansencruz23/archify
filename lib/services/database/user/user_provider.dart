import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/base_provider.dart';
import 'package:archify/services/database/user/user_service.dart';

class UserProvider extends BaseProvider {
  final _authService = AuthService();
  final _userService = UserService();

  // Save user after registering
  Future<void> saveUser(String email) async {
    await _userService.saveUserInFirebase(email);
  }
}
