import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  // Login with email and password
  Future<UserCredential> loginEmailPasswordInFirebase(
      String email, password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.code);
    }
  }

  // Register
  Future<UserCredential> registerEmailPasswordInFirebase(
      String email, password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.code);
    }
  }

  // Logout
  Future<void> logoutInFirebase() async {
    await _auth.signOut();
  }

  // Delete account
}
