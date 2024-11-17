import 'package:archify/models/day.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

class DayService {
  final _db = FirebaseFirestore.instance;
  final _authService = AuthService();
  final _storage = FirebaseStorage.instance;

  final logger = Logger('UserService');

  // Save day details in Firebase
  Future<String> createDayInFirebase(Day day) async {
    try {
      final docRef = _db.collection('Days').doc();
      day.id = docRef.id;

      final dayMap = day.toMap();
      await docRef.set(dayMap);

      return day.id;
    } catch (ex) {
      logger.severe(ex.toString());
      return '';
    }
  }

  // Get day details from Firebase
  Future<Day?> getDayFromFirebase(String dayId) async {
    try {
      final dayDoc = await _db.collection('Days').doc(dayId).get();
      return Day.fromDocument(dayDoc);
    } catch (ex) {
      logger.severe(ex.toString());
      return null;
    }
  }

  // Start the day
  Future<void> startDayInFirebase(String dayId, String nickname) async {
    try {
      final currentUserId = _authService.getCurrentUid();
      await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .doc(currentUserId)
          .set({
        'uid': currentUserId,
        'role': 'host',
        'nickname': nickname,
      });
    } catch (ex) {
      logger.severe(ex.toString());
    }
  }
}
