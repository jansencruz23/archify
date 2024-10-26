import 'package:archify/models/user_profile.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _authService = AuthService();
  final _storage = FirebaseStorage.instance;

  final logger = Logger('UserService');

  // Save user profile in Firebase
  Future<void> saveUserInFirebase(String email) async {
    final uid = _authService.getCurrentUid();
    final username = email.split('@')[0];
    final user = UserProfile(
      uid: uid,
      name: 'Anon',
      email: email,
      username: username,
      bio: '',
      pictureUrl: '',
      isNew: true,
    );

    final userMap = user.toMap();
    await _db.collection('Users').doc(uid).set(userMap);
  }

  // Gets user profile from the database
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      final userDoc = await _db.collection('Users').doc(uid).get();
      return UserProfile.fromDocument(userDoc);
    } catch (ex) {
      logger.severe(ex.toString());
      return null;
    }
  }

  // Update user's isNew property in database
  Future<void> updateUserNotNewInFirebase() async {
    try {
      final uid = AuthService().getCurrentUid();
      await _db.collection('Users').doc(uid).update({'isNew': false});
    } catch (ex) {
      logger.severe(ex.toString());
    }
  }
}
