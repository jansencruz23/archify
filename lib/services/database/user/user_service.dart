import 'package:archify/models/joined_day.dart';
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

  // Gets user profile from the database
  Future<UserProfile?> getUserByEmailFromFirebase(String email) async {
    try {
      final userDoc = await _db
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return UserProfile.fromDocument(userDoc.docs.first);
    } catch (ex) {
      logger.severe(ex.toString());
      return null;
    }
  }

  // Update user's isNew property in database
  Future<void> updateUserAfterSetupInFirebase(
      {required String name, required String pictureUrl}) async {
    try {
      final uid = AuthService().getCurrentUid();
      await _db.collection('Users').doc(uid).update({
        'name': name,
        'pictureUrl': pictureUrl,
        'isNew': false,
      });
    } catch (ex) {
      logger.severe(ex.toString());
    }
  }

  Future<void> addDayToUserProfile(String dayId, String uid) async {
    try {
      final userDays = await _db
          .collection('Users')
          .doc(uid)
          .collection('JoinedDays')
          .doc(dayId)
          .get();

      if (userDays.exists) {
        return;
      }

      final day = JoinedDay(dayId: dayId, date: DateTime.now().toUtc());

      await _db
          .collection('Users')
          .doc(uid)
          .collection('JoinedDays')
          .doc(dayId)
          .set(day.toMap());
    } catch (ex) {
      logger.severe(ex.toString());
    }
  }

  Future<String?> getJoinedDayIdToday() async {
    try {
      final uid = _authService.getCurrentUid();
      final today = DateTime.now().toUtc().add(Duration(hours: 8));
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final joined = await _db
          .collection('Users')
          .doc(uid)
          .collection('JoinedDays')
          .where('date', isGreaterThanOrEqualTo: todayStart)
          .where('date', isLessThanOrEqualTo: todayEnd)
          .get();

      if (joined.docs.isEmpty) {
        return null;
      }

      final joinedDay = JoinedDay.fromDocument(joined.docs.first.data());
      return joinedDay.dayId;
    } catch (ex) {
      logger.severe(ex.toString());
      return null;
    }
  }
}
