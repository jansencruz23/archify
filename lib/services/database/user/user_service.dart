import 'package:archify/models/comment.dart';
import 'package:archify/models/day.dart';
import 'package:archify/models/favorite_day.dart';
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

  final _logger = Logger('UserService');

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
      if (!userDoc.exists) return null;
      final user = UserProfile.fromDocument(userDoc.data()!);
      user.favoriteDays = await getFavoriteDaysFromFirebase();
      return user;
    } catch (ex) {
      _logger.severe(ex.toString());
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

      return UserProfile.fromDocument(userDoc.docs.first.data());
    } catch (ex) {
      _logger.severe(ex.toString());
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
      _logger.severe(ex.toString());
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

      final day = JoinedDay(dayId: dayId, date: DateTime.now());

      await _db
          .collection('Users')
          .doc(uid)
          .collection('JoinedDays')
          .doc(dayId)
          .set(day.toMap());
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<String?> getJoinedDayIdToday() async {
    try {
      final uid = _authService.getCurrentUid();
      final now = DateTime.now();
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
      final dayDate = joinedDay.date;

      if (dayDate.isBefore(todayStart) || dayDate.isAfter(todayEnd)) {
        return null;
      }

      return joinedDay.dayId;
    } catch (ex) {
      _logger.severe(ex.toString());
      return null;
    }
  }

  Future<List<Moment>> getUserMomentsFromFirebase() async {
    try {
      final moments = <Moment>[];
      final uid = _authService.getCurrentUid();

      // Fetch joined days
      final joinedDaysSnapshot = await _db
          .collection('Users')
          .doc(uid)
          .collection('JoinedDays')
          .orderBy('date', descending: true)
          .get();

      // Check if there are joined days
      if (joinedDaysSnapshot.docs.isEmpty) return moments;

      // Fetch days and moments in parallel
      final dayFutures = joinedDaysSnapshot.docs.map((dayDoc) async {
        final dayId = dayDoc.data()['dayId'];
        final daySnapshot = await _db.collection('Days').doc(dayId).get();
        final dayData = daySnapshot.data();

        if (dayData == null ||
            dayData['winnerId'] == null ||
            dayData['winnerId'].isEmpty) return null;

        final winnerId = dayData['winnerId'];
        final momentSnapshot = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Moments')
            .doc(winnerId)
            .get();

        if (!momentSnapshot.exists) return null;

        final moment = Moment.fromDocument(momentSnapshot.data()!);
        moment.dayName = dayData['name'];

        // Fetch comments in parallel
        final commentsSnapshot = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Comments')
            .orderBy('date')
            .get();

        final commentFutures = commentsSnapshot.docs.map((commentDoc) async {
          final comment = Comment.fromDocument(commentDoc.data());
          final userSnapshot =
              await _db.collection('Users').doc(comment.uid).get();
          final user = userSnapshot.data();
          comment.profilePictureUrl = user?['pictureUrl'] ?? '';
          return comment;
        });

        moment.comments = await Future.wait(commentFutures);
        return moment;
      }).toList();

      // Wait for all moments to be fetched
      final fetchedMoments = await Future.wait(dayFutures);
      moments.addAll(fetchedMoments.whereType<Moment>());

      return moments;
    } catch (ex) {
      _logger.severe('Error fetching user moments: ${ex.toString()}');
      return [];
    }
  }

  Future<void> addToFavoritesInFirebase(String dayId) async {
    try {
      final dayRef = await _db.collection('Days').doc(dayId).get();
      if (!dayRef.exists) return;

      final day = Day.fromDocument(dayRef.data()!);
      final uid = _authService.getCurrentUid();
      final favoriteDoc = await _db
          .collection('Users')
          .doc(uid)
          .collection('FavoriteDays')
          .doc(dayId)
          .get();

      if (favoriteDoc.exists) {
        // User has already favorited the day, so we remove it
        await favoriteDoc.reference.delete();
      } else {
        final favoriteDay = FavoriteDay(
          dayId: dayId,
          date: day.createdAt,
        );

        // User has not faved the image, so we add to the favoriteDays collection
        await _db
            .collection('Users')
            .doc(uid)
            .collection('FavoriteDays')
            .doc(dayId)
            .set(favoriteDay.toMap());
      }
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<List<Moment>> getFavoriteDaysFromFirebase() async {
    try {
      final moments = <Moment>[];
      final uid = _authService.getCurrentUid();

      // Fetch favorite days
      final favoriteDaysSnapshot = await _db
          .collection('Users')
          .doc(uid)
          .collection('FavoriteDays')
          .orderBy('date', descending: true)
          .get();

      if (favoriteDaysSnapshot.docs.isEmpty) return moments;

      // Fetch all day documents in parallel
      final dayFutures = favoriteDaysSnapshot.docs.map((dayDoc) async {
        final dayId = dayDoc.data()['dayId'];
        return _db.collection('Days').doc(dayId).get();
      }).toList();

      final daySnapshots = await Future.wait(dayFutures);

      // Filter out non-existing days
      final validDaySnapshots =
          daySnapshots.where((snapshot) => snapshot.exists).toList();

      // Fetch all moments in parallel
      final momentFutures = validDaySnapshots.map((daySnapshot) async {
        final dayData = daySnapshot.data()!;
        final winnerId = dayData['winnerId'];
        if (winnerId == null || winnerId.isEmpty) return null;

        final momentDoc = await _db
            .collection('Days')
            .doc(daySnapshot.id)
            .collection('Moments')
            .doc(winnerId)
            .get();
        if (!momentDoc.exists) return null;

        final moment = Moment.fromDocument(momentDoc.data()!);
        moment.dayName = dayData['name'];

        // Fetch comments in parallel
        final commentsSnapshot = await _db
            .collection('Days')
            .doc(daySnapshot.id)
            .collection('Comments')
            .orderBy('date')
            .get();

        final commentFutures = commentsSnapshot.docs.map((commentDoc) async {
          final comment = Comment.fromDocument(commentDoc.data());
          final userSnapshot =
              await _db.collection('Users').doc(comment.uid).get();
          final user = userSnapshot.data();
          comment.profilePictureUrl = user?['pictureUrl'] ?? '';
          return comment;
        }).toList();

        moment.comments = await Future.wait(commentFutures);
        return moment;
      }).toList();

      final fetchedMoments = await Future.wait(momentFutures);
      moments.addAll(fetchedMoments.whereType<Moment>());

      return moments;
    } catch (ex) {
      _logger.severe('Error fetching favorite days: ${ex.toString()}');
      return [];
    }
  }
}
