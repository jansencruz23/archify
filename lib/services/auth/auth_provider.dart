import 'package:archify/services/auth/auth_service.dart';
import 'package:archify/services/base_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends BaseProvider {
  final _authService = AuthService();

  User? getCurrentUser() => _authService.getCurrentUser();
  String getCurrentUid() => _authService.getCurrentUid();

  // Login
  Future<void> loginEmailPassword(String email, password) async {
    await _authService.loginEmailPasswordInFirebase(email, password);
  }

  // Login with Google
  Future<UserCredential?> loginWithGoogle() async {
    return await _authService.loginWithGoogle();
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
