import 'package:archify/models/comment.dart';
import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/models/participant.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';

class DayService {
  final _db = FirebaseFirestore.instance;
  final _authService = AuthService();

  final _logger = Logger('UserService');
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Map<String, Participant> _participantCache = {};

  // Save day details in Firebase
  Future<String> createDayInFirebase(Day day) async {
    try {
      final docRef = _db.collection('Days').doc();
      day.id = docRef.id;

      final dayMap = day.toMap();
      await docRef.set(dayMap);

      return day.id;
    } catch (ex) {
      _logger.severe(ex.toString());
      return '';
    }
  }

  // Get day details from Firebase
  Future<Day?> getDayFromFirebase(String dayId) async {
    try {
      final dayDoc = await _db.collection('Days').doc(dayId).get();
      if (!dayDoc.exists || dayDoc.data() == null) return null;

      return Day.fromDocument(dayDoc.data()!);
    } catch (ex) {
      _logger.severe(ex.toString());
      return null;
    }
  }

  // Start the day
  Future<void> startDayInFirebase(
      String dayCode, String nickname, String avatar) async {
    try {
      final day = await getDayByCodeFromFirebase(dayCode);
      if (day == null) return;

      final currentUserId = _authService.getCurrentUid();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      final participant = Participant(
        uid: currentUserId,
        role: day.hostId == currentUserId ? 'host' : 'participant',
        nickname: nickname,
        fcmToken: fcmToken,
        avatar: avatar,
        hasUploaded: false,
      );

      final participantDocRef = _db
          .collection('Days')
          .doc(day.id)
          .collection('Participants')
          .doc(currentUserId);

      final batch = _db.batch();
      batch.set(participantDocRef, participant.toMap());

      await batch.commit();
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<bool> isRoomFull(String dayCode) async {
    try {
      final day = await getDayByCodeFromFirebase(dayCode);
      if (day == null) return false;

      final currentParticipantCountSnapshot = await _db
          .collection('Days')
          .doc(day.id)
          .collection('Participants')
          .count()
          .get();

      final currentParticipantCount = currentParticipantCountSnapshot.count;
      return day.maxParticipants <= currentParticipantCount!;
    } catch (ex) {
      _logger.severe(ex.toString());
      return true;
    }
  }

  Future<void> sendImageToFirebase(String imageUrl, String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) return;

      final uid = _authService.getCurrentUid();
      final participantDocRef =
          _db.collection('Days').doc(dayId).collection('Participants').doc(uid);

      final participantDoc = await participantDocRef.get();
      if (!participantDoc.exists) return;

      final participant = Participant.fromDocument(participantDoc.data()!);
      participant.hasUploaded = true;

      final moment = Moment(
        momentId: '',
        imageUrl: imageUrl,
        uploadedBy: uid,
        uploadedAt: DateTime.now(),
        dayId: dayId,
      );

      final momentDocRef =
          _db.collection('Days').doc(dayId).collection('Moments').doc();
      moment.momentId = momentDocRef.id;

      // Use a WriteBatch to perform multiple write operations in a single request
      final batch = _db.batch();
      batch.set(momentDocRef, moment.toMap());
      batch.update(participantDocRef, participant.toMap());

      await batch.commit();
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<bool> isDayExistingAndActiveInFirebase(String dayCode) async {
    try {
      // Fetch day document by code
      final dayQuerySnapshot = await _db
          .collection('Days')
          .where('code', isEqualTo: dayCode)
          .limit(1)
          .get();

      // Check if no documents are found
      if (dayQuerySnapshot.docs.isEmpty) return false;

      // Get the first document and map it to a Day object
      final dayDoc = dayQuerySnapshot.docs.first;
      final day = Day.fromDocument(dayDoc.data());

      // Check if the day is inactive
      if (!day.status) return false;

      // Check if the voting deadline has passed
      if (day.votingDeadline.isBefore(DateTime.now())) {
        await dayDoc.reference.update({'status': false});
        return false;
      }

      // Return the status of the day
      return day.status;
    } catch (ex) {
      _logger.severe(ex.toString());
      return false;
    }
  }

  Future<String> getDayIdFromFirebase(String dayCode) async {
    try {
      final querySnapshot = await _db
          .collection('Days')
          .where('code', isEqualTo: dayCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return '';

      final dayDoc = querySnapshot.docs.first;
      final day = Day.fromDocument(dayDoc.data());
      return day.id;
    } catch (ex) {
      _logger.severe(ex.toString());
      return '';
    }
  }

  Future<Day?> getDayByCodeFromFirebase(String dayCode) async {
    try {
      final querySnapshot = await _db
          .collection('Days')
          .where('code', isEqualTo: dayCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return Day.fromDocument(querySnapshot.docs.first.data());
    } catch (ex) {
      _logger.severe(ex.toString());
      return null;
    }
  }

  Future<List<Moment>> getMomentsFromFirebase(String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) {
        return [];
      }

      final momentsDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Moments')
          .orderBy('uploadedAt', descending: true)
          .get();

      final moments = momentsDoc.docs
          .map((doc) => Moment.fromDocument(doc.data()))
          .toList();

      for (var moment in moments) {
        final participantDoc = await getParticipantsFromFirebase(dayId);
        final participant = participantDoc.firstWhere(
          (element) => element.uid == moment.uploadedBy,
          orElse: () => Participant(
            uid: '',
            role: '',
            nickname: '',
            fcmToken: '',
            avatar: '',
            hasUploaded: false,
          ),
        );

        moment.nickname = participant.nickname;
        moment.avatarId = participant.avatar;
      }

      return moments;
    } catch (ex) {
      _logger.severe(ex.toString());
      return [];
    }
  }

  Stream<List<Moment>> momentsStream(String dayId) {
    try {
      return _db
          .collection('Days')
          .doc(dayId)
          .collection('Moments')
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .asyncMap(
        (snapshot) async {
          final moments = snapshot.docs
              .map((doc) => Moment.fromDocument(doc.data()))
              .toList();
          final participantIds =
              moments.map((moment) => moment.uploadedBy).toSet();

          await _fetchParticipantsInBulk(participantIds, dayId);

          for (var moment in moments) {
            final participant =
                _participantCache['${moment.uploadedBy} $dayId'];
            if (participant != null) {
              moment.nickname = participant.nickname;
              moment.avatarId = participant.avatar;
            }
          }
          return moments;
        },
      );
    } catch (ex) {
      _logger.severe(ex.toString());
      return Stream.value([]);
    }
  }

  Future<void> _fetchParticipantsInBulk(
      Set<String> participantIds, String dayId) async {
    try {
      final idsToFetch = participantIds
          .where((uid) => !_participantCache.containsKey('$uid $dayId'))
          .toList();

      if (idsToFetch.isNotEmpty) {
        final participantDocs = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Participants')
            .where(FieldPath.documentId, whereIn: idsToFetch)
            .get();

        for (var doc in participantDocs.docs) {
          final participant = Participant.fromDocument(doc.data());
          _participantCache['${doc.id} $dayId'] = participant;
        }
      }
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<List<Participant>> getParticipantsFromFirebase(String dayId) async {
    try {
      final participantsDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .get();

      final participants = participantsDoc.docs
          .map((doc) => Participant.fromDocument(doc.data()))
          .toList();
      return participants;
    } catch (ex) {
      _logger.severe(ex.toString());
      return [];
    }
  }

  Future<void> toggleVoteInFirebase(String dayCode, String imageId) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) return;

      final currentUid = _authService.getCurrentUid();
      final momentDocRef =
          _db.collection('Days').doc(dayId).collection('Moments').doc(imageId);
      final likeDocRef = momentDocRef.collection('Likes').doc(currentUid);

      final batch = _db.batch();

      final likeDocSnapshot = await likeDocRef.get();
      final momentDocSnapshot = await momentDocRef.get();

      if (!momentDocSnapshot.exists) return;

      final momentData = momentDocSnapshot.data();
      if (momentData == null) return;

      final moment = Moment.fromDocument(momentData);

      if (likeDocSnapshot.exists) {
        batch.delete(likeDocRef);
        moment.votes -= 1;
      } else {
        batch.set(likeDocRef, <String, dynamic>{});
        moment.votes += 1;
      }

      batch.update(momentDocRef, {'votes': moment.votes});
      await batch.commit();
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<bool> isParticipant(String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) return false;

      final currentUid = _authService.getCurrentUid();
      final participantDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .doc(currentUid)
          .get();

      return participantDoc.exists;
    } catch (ex) {
      _logger.severe(ex.toString());
      return false;
    }
  }

  Future<bool> hasParticipantUploaded(String dayCode) async {
    try {
      final uid = _authService.getCurrentUid();
      final dayId = await getDayIdFromFirebase(dayCode);

      if (dayId.isEmpty) return false;

      final participantDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .doc(uid)
          .get();

      if (!participantDoc.exists) return false;

      final participantData = participantDoc.data();
      if (participantData == null) return false;

      return participantData['hasUploaded'] as bool? ?? false;
    } catch (ex) {
      _logger.severe(ex.toString());
      return false;
    }
  }

  Future<void> getWinnerFromFirebase(String dayId) async {
    try {
      final dayDocRef = _db.collection('Days').doc(dayId);

      // Batch updates for performance
      final batch = _db.batch();

      // Update the status to false
      batch.update(dayDocRef, {'status': false});

      // Retrieve the top voted moment
      final momentsSnapshot = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Moments')
          .orderBy('votes', descending: true)
          .limit(1)
          .get();

      if (momentsSnapshot.docs.isNotEmpty) {
        final winnerDoc = momentsSnapshot.docs.first;
        final momentData = winnerDoc.data();

        if (momentData.isNotEmpty) {
          final moment = Moment.fromDocument(momentData);
          batch.update(dayDocRef, {'winnerId': moment.momentId});
        }
      }

      // Commit the batch updates
      await batch.commit();
    } catch (ex) {
      _logger.severe('Error getting winner from Firebase: $ex');
    }
  }

  Future<bool> hasVotingDeadlineExpired(String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) return true;

      final dayDoc = await _db.collection('Days').doc(dayId).get();
      if (!dayDoc.exists) return true;

      final day = Day.fromDocument(dayDoc.data()!);
      final now = DateTime.now();
      final votingDeadline = day.votingDeadline;

      final isVotingActive = votingDeadline.isAfter(now);
      if (!isVotingActive) {
        await getWinnerFromFirebase(dayId);
        return true;
      }

      if (!day.status) return true;

      return !isVotingActive;
    } catch (ex) {
      _logger.severe(ex.toString());
      return false;
    }
  }

  Future<void> sendCommentToFirebase(String comment, String dayId) async {
    try {
      final uid = _authService.getCurrentUid();
      final now = DateTime.now();

      final commentRef =
          _db.collection('Days').doc(dayId).collection('Comments').doc();

      final commentModel = Comment(
        commentId: commentRef.id,
        dayId: dayId,
        uid: uid,
        date: now,
        content: comment,
      );

      await commentRef.set(commentModel.toMap());
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<List<String>> getVotedMomentIdsFromFirebase(String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) return [];

      final uid = _authService.getCurrentUid();
      final likesDoc =
          await _db.collection('Days').doc(dayId).collection('Moments').get();
      final votedMomentIds = <String>[];

      for (var moment in likesDoc.docs) {
        final likes = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Moments')
            .doc(moment.id)
            .collection('Likes')
            .get();
        if (likes.docs.any((like) => like.id == uid)) {
          votedMomentIds.add(moment.id);
        }
      }
      return votedMomentIds;
    } catch (ex) {
      _logger.severe(ex.toString());
      return [];
    }
  }

  Stream<List<Comment>> commentsStream(String dayId) {
    if (dayId.isEmpty) return Stream.value([]);
    return _db
        .collection('Days')
        .doc(dayId)
        .collection('Comments')
        .orderBy('date')
        .snapshots()
        .asyncMap((snapshot) async {
      final userIds = snapshot.docs
          .map((doc) => doc.data()['uid'])
          .toSet()
          .where((uid) => uid != null)
          .toList();
      await _fetchUserDataInBulk(userIds);
      return snapshot.docs.map((doc) {
        final comment = Comment.fromDocument(doc.data());
        final user = _userCache[comment.uid];
        if (user != null) {
          comment.profilePictureUrl = user['pictureUrl'] ?? '';
        }
        return comment;
      }).toList();
    });
  }

  void resetUserCache() {
    _userCache.clear();
  }

  Future<void> _fetchUserDataInBulk(List<dynamic> userIds) async {
    final userIdsToFetch =
        userIds.where((uid) => !_userCache.containsKey(uid)).toList();
    if (userIdsToFetch.isNotEmpty) {
      final userDocs = await _db
          .collection('Users')
          .where(FieldPath.documentId, whereIn: userIdsToFetch)
          .get();
      for (var userDoc in userDocs.docs) {
        _userCache[userDoc.id] = userDoc.data();
      }
    }
  }

  Future<bool> isHost(String dayId) async {
    try {
      final uid = _authService.getCurrentUid();

      // Fetch the day document once and directly check the hostId field
      final dayDoc = await _db.collection('Days').doc(dayId).get();

      if (!dayDoc.exists) return false;

      final hostId = dayDoc.data()?['hostId'] as String?;
      return hostId == uid;
    } catch (ex) {
      _logger.severe(ex.toString());
      return false;
    }
  }

  Future<void> leaveDayInFirebase(String dayId) async {
    try {
      final uid = _authService.getCurrentUid();
      final batch = _db.batch();

      // Remove the user from Participants collection
      final participantRef =
          _db.collection('Days').doc(dayId).collection('Participants').doc(uid);
      batch.delete(participantRef);

      // Delete user's moments
      final momentsSnapshot = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Moments')
          .where('uploadedBy', isEqualTo: uid)
          .get();
      for (var moment in momentsSnapshot.docs) {
        batch.delete(moment.reference);
      }

      // Adjust votes and delete likes
      final momentsWithLikesSnapshot =
          await _db.collection('Days').doc(dayId).collection('Moments').get();
      for (var moment in momentsWithLikesSnapshot.docs) {
        final likesSnapshot = await moment.reference
            .collection('Likes')
            .where(FieldPath.documentId, isEqualTo: uid)
            .get();
        if (likesSnapshot.docs.isNotEmpty) {
          final momentData = moment.data();
          for (var like in likesSnapshot.docs) {
            batch.delete(like.reference);
          }
          if (momentData['votes'] != null) {
            moment.reference.update({'votes': momentData['votes'] - 1});
          }
        }
      }
      // Remove the day from the user's joined days
      final joinedDayRef =
          _db.collection('Users').doc(uid).collection('JoinedDays').doc(dayId);
      batch.delete(joinedDayRef);

      // Commit the batch
      await batch.commit();
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<Day?> updateDayInFirebase({
    required String dayId,
    required String dayName,
    required int maxParticipants,
    required DateTime votingDeadline,
  }) async {
    try {
      final dayDocRef = _db.collection('Days').doc(dayId);
      await dayDocRef.update({
        'name': dayName,
        'maxParticipants': maxParticipants,
        'votingDeadline': votingDeadline,
      });
      return Day.fromDocument((await dayDocRef.get()).data()!);
    } catch (ex) {
      _logger.severe(ex.toString());
      return null;
    }
  }

  Future<int> getParticipantCount(String dayId) async {
    try {
      final participantsSnapshot = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .get();
      return participantsSnapshot.size;
    } catch (ex) {
      _logger.severe(ex.toString());
      return 0;
    }
  }

  Future<void> deleteDayInFirebase(String dayId) async {
    try {
      final batch = _db.batch();

      // Delete all participants
      final participantsSnapshot = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .get();
      for (var participant in participantsSnapshot.docs) {
        batch.delete(participant.reference);
      }

      // Delete all moments
      final momentsSnapshot =
          await _db.collection('Days').doc(dayId).collection('Moments').get();
      for (var moment in momentsSnapshot.docs) {
        batch.delete(moment.reference);
      }

      // Delete all comments
      final commentsSnapshot =
          await _db.collection('Days').doc(dayId).collection('Comments').get();
      for (var comment in commentsSnapshot.docs) {
        batch.delete(comment.reference);
      }

      // Delete the day
      batch.delete(_db.collection('Days').doc(dayId));

      // Delete the day from all users' joined days
      final usersSnapshot = await _db.collection('Users').get();
      for (var user in usersSnapshot.docs) {
        final joinedDaysSnapshot = await user.reference
            .collection('JoinedDays')
            .where(FieldPath.documentId, isEqualTo: dayId)
            .get();
        for (var joinedDay in joinedDaysSnapshot.docs) {
          batch.delete(joinedDay.reference);
        }
      }

      // Commit the batch
      await batch.commit();
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }
}
