import 'package:archify/models/comment.dart';
import 'package:archify/models/day.dart';
import 'package:archify/models/joined_day.dart';
import 'package:archify/models/moment.dart';
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
      final now = DateTime.now().add(Duration(hours: 8));
      final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final joined = await _db
          .collection('Users')
          .doc(uid)
          .collection('JoinedDays')
          .orderBy('date', descending: true)
          .get();

      if (joined.docs.isEmpty) {
        return null;
      }

      final joinedDay = JoinedDay.fromDocument(joined.docs.first.data());
      final dayDate = joinedDay.date.add(Duration(hours: 8));

      if (dayDate.isBefore(todayStart) || dayDate.isAfter(todayEnd)) {
        return null;
      }

      return joinedDay.dayId;
    } catch (ex) {
      logger.severe(ex.toString());
      return null;
    }
  }

  Future<List<Moment>> getUserMomentsFromFirebase() async {
    try {
      final moments = List<Moment>.empty(growable: true);
      final uid = _authService.getCurrentUid();
      final joinedDays = await _db
          .collection('Users')
          .doc(uid)
          .collection('JoinedDays')
          .orderBy('date', descending: true)
          .get();

      for (final day in joinedDays.docs) {
        final dayId = day.data()['dayId'];
        final dayMoments = await _db.collection('Days').doc(dayId).get();
        final dayData = dayMoments.data();
        if (dayData == null) continue;
        final validDay = dayData['winnerId'] != "";

        if (!validDay) continue;

        final winnerId = dayMoments.data()?['winnerId'];
        if (winnerId == null || winnerId.isEmpty) continue;

        final momentDoc = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Moments')
            .doc(winnerId)
            .get();

        final moment = Moment.fromDocument(momentDoc.data()!);
        moment.dayName = dayMoments.data()!['name'];

        final commentsRef = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Comments')
            .orderBy('date')
            .get();

        final comments = commentsRef.docs;

        for (var commentRef in comments) {
          final comment = Comment.fromDocument(commentRef.data());
          final userDoc = await _db.collection('Users').doc(comment.uid).get();
          final user = userDoc.data();
          comment.profilePictureUrl = user?['pictureUrl'] ?? '';
          moment.comments.add(comment);
        }

        moments.add(moment);
      }

      return moments;
    } catch (ex) {
      logger.severe(ex.toString());
      return [];
    }
  }
}
