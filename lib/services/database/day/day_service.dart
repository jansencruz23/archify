import 'package:archify/models/comment.dart';
import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/models/participant.dart';
import 'package:archify/models/user_profile.dart';
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
  Future<void> startDayInFirebase(String dayCode, String nickname) async {
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
        hasUploaded: false,
      );
      final participantDocRef = _db
          .collection('Days')
          .doc(day.id)
          .collection('Participants')
          .doc(currentUserId);

      // Use a WriteBatch to perform the write operation
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
      if (dayId.isEmpty) return [];

      final momentsDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Moments')
          .orderBy('uploadedAt', descending: true)
          .get();

      final moments = momentsDoc.docs
          .map((doc) => Moment.fromDocument(doc.data()))
          .toList();

      final participantIds = moments.map((moment) => moment.uploadedBy).toSet();
      final participantSnapshot = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .where(FieldPath.documentId, whereIn: participantIds.toList())
          .get();

      final participants = participantSnapshot.docs
          .map((doc) => Participant.fromDocument(doc.data()))
          .toList();

      final participantMap = {
        for (var participant in participants) participant.uid: participant
      };

      for (var moment in moments) {
        moment.nickname = participantMap[moment.uploadedBy]?.nickname ?? '';
      }

      return moments;
    } catch (ex) {
      _logger.severe(ex.toString());
      return [];
    }
  }

  Stream<List<Moment>> momentsStream(String dayId) {
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
          final participant = _participantCache[moment.uploadedBy];
          if (participant != null) {
            moment.nickname = participant.nickname;
          }
        }

        return moments;
      },
    );
  }

  Future<void> _fetchParticipantsInBulk(
      Set<String> participantIds, String dayId) async {
    final idsToFetch = participantIds
        .where((id) => !_participantCache.containsKey(id))
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
        _participantCache[doc.id] = participant;
      }
    }
  }

  Future<List<Participant>> getParticipantsFromFirebase(String dayId) async {
    try {
      final participantsSnapshot = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .get();

      return participantsSnapshot.docs
          .map((doc) => Participant.fromDocument(doc.data()))
          .toList();
    } catch (ex) {
      _logger.severe(ex.toString());
      return [];
    }
  }

  Future<void> toggleVoteInFirebase(String dayCode, String imageId) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) {
        return;
      }

      final currentUid = _authService.getCurrentUid();
      final momentDocRef =
          _db.collection('Days').doc(dayId).collection('Moments').doc(imageId);
      final likeDocRef = momentDocRef.collection('Likes').doc(currentUid);

      final likeDocSnapshot = await likeDocRef.get();
      final batch = _db.batch();

      final momentDocSnapshot = await momentDocRef.get();
      if (!momentDocSnapshot.exists) return;

      final momentData = momentDocSnapshot.data();
      if (momentData == null) return;

      final moment = Moment.fromDocument(momentData);

      if (likeDocSnapshot.exists) {
        // User has already voted the image, so we remove the like
        batch.delete(likeDocRef);
        moment.votes -= 1;
      } else {
        // User has not liked the image, so we add the like
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

      final participant = Participant.fromDocument(participantDoc.data()!);
      return participant.hasUploaded;
    } catch (ex) {
      _logger.severe(ex.toString());
      return false;
    }
  }

  Future<void> getWinnerFromFirebase(String dayId) async {
    try {
      await _db.collection('Days').doc(dayId).update({'status': false});

      final moments = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Moments')
          .orderBy('votes', descending: true)
          .limit(1)
          .get();

      if (moments.docs.isNotEmpty) {
        final winner = moments.docs.first;
        if (winner.data().isEmpty) return;

        final moment = Moment.fromDocument(winner.data());
        await _db
            .collection('Days')
            .doc(dayId)
            .update({'winnerId': moment.momentId});
      }
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<bool> hasVotingDeadlineExpired(String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) return true;

      final dayDoc = await _db.collection('Days').doc(dayId).get();
      if (!dayDoc.exists) return true;

      final day = Day.fromDocument(dayDoc.data()!);
      // Adjusting for the timezone difference to ensure the correct comparison
      final now = DateTime.now();
      final votingDeadline = day.votingDeadline;
      final isVotingActive = votingDeadline.isAfter(now);

      if (!isVotingActive) {
        await getWinnerFromFirebase(dayId);
      }

      if (!day.status) {
        return true;
      }

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
      final commentModel = Comment(
        commentId: '',
        dayId: dayId,
        uid: uid,
        date: now,
        content: comment,
      );

      final commentRef =
          _db.collection('Days').doc(dayId).collection('Comments').doc();

      commentModel.commentId = commentRef.id;
      await commentRef.set(commentModel.toMap());
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<List<String>> getVotedMomentIdsFromFirebase(String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
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
      final dayDoc = await _db.collection('Days').doc(dayId).get();
      if (!dayDoc.exists) return false;

      final day = Day.fromDocument(dayDoc.data()!);
      return day.hostId == uid;
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
}
