import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/base_provider.dart';

class AuthProvider extends BaseProvider {
  final _authService = AuthService();

  // Login
  Future<void> loginEmailPassword(String email, password) async {
    await _authService.loginEmailPasswordInFirebase(email, password);
  }

  // Register
  Future<void> registerEmailPassword(String email, password) async {
    await _authService.registerEmailPasswordInFirebase(email, password);
  }

  // Logout
  Future<void> logout() async {
    await _authService.logoutInFirebase();
  }
}
