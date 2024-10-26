import 'package:archify/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  // Save user profile in Firebase
  Future<void> saveUserInFirebase(String email) async {
    var uid = _auth.currentUser!.uid;
    var username = email.split('@')[0];
    var user = UserProfile(
      uid: uid,
      name: 'Anon',
      email: email,
      username: username,
      bio: '',
      pictureUrl: '',
    );

    final userMap = user.toMap();
    await _db.collection('Users').doc(uid).set(userMap);
  }
}
