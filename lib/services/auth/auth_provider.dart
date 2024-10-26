import 'package:archify/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Login
  Future<void> loginEmailPassword(String email, password) async {
    await _auth.loginEmailPasswordInFirebase(email, password);
  }

  // Register
  Future<void> registerEmailPassword(String email, password) async {
    await _auth.registerEmailPasswordInFirebase(email, password);
  }

  // Logout
  Future<void> logout() async {
    await _auth.logoutInFirebase();
  }
}
