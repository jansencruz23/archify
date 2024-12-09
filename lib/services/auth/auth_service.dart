import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser?.uid ?? '';

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

  // Login with google
  Future<UserCredential?> loginWithGoogle() async {
    try {
      // Sign in with google pop up
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      // Get auth details from request
      final googleAuth = await googleUser.authentication;

      // Create a new credential for user
      final crendential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(crendential);
    } catch (e) {
      print(e);
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
    await GoogleSignIn().signOut();
  }

  // Delete account
}
