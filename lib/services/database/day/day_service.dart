import 'package:archify/models/day.dart';
import 'package:archify/models/user_profile.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DayService {
  final _db = FirebaseFirestore.instance;
  final _authService = AuthService();
  final _storage = FirebaseStorage.instance;

  // Save day details in Firebase
  Future<void> createDayInFirebase(Day day) async {
    final docRef = _db.collection('Days').doc();
    day.id = docRef.id;

    final dayMap = day.toMap();
    await docRef.set(dayMap);
  }
}
