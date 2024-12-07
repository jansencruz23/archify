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
      await _db
          .collection('Days')
          .doc(day.id)
          .collection('Participants')
          .doc(currentUserId)
          .set(participant.toMap());
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<bool> isRoomFull(String dayCode) async {
    try {
      final day = await getDayByCodeFromFirebase(dayCode);
      if (day == null) {
        return false;
      }

      final currentParticipantCount = await _db
          .collection('Days')
          .doc(day.id)
          .collection('Participants')
          .count()
          .get()
          .then((value) => value.count);

      if (currentParticipantCount == null) {
        return true;
      }

      return day.maxParticipants <= currentParticipantCount;
    } catch (ex) {
      _logger.severe(ex.toString());
      return true;
    }
  }

  Future<void> sendImageToFirebase(String imageUrl, String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) {
        return;
      }

      final uid = _authService.getCurrentUid();
      final participantDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .doc(uid)
          .get();

      if (!participantDoc.exists) {
        return;
      }

      final participant = Participant.fromDocument(participantDoc.data()!);
      participant.hasUploaded = true;

      final moment = Moment(
        momentId: '',
        imageUrl: imageUrl,
        uploadedBy: _authService.getCurrentUid(),
        uploadedAt: DateTime.now(),
        dayId: dayId,
      );

      final docRef =
          _db.collection('Days').doc(dayId).collection('Moments').doc();
      moment.momentId = docRef.id;

      await docRef.set(moment.toMap());
      await participantDoc.reference.update(participant.toMap());
    } catch (ex) {
      _logger.severe(ex.toString());
    }
  }

  Future<bool> isDayExistingAndActiveInFirebase(String dayCode) async {
    try {
      final dayDoc =
          await _db.collection('Days').where('code', isEqualTo: dayCode).get();
      if (dayDoc.docs.isEmpty) {
        return false;
      }

      final day = Day.fromDocument(dayDoc.docs.first.data());

      if (day.status == false) {
        return false;
      }

      if (day.votingDeadline.isBefore(DateTime.now())) {
        await _db.collection('Days').doc(day.id).update({'status': false});
        return false;
      }

      return day.status;
    } catch (ex) {
      _logger.severe(ex.toString());
      return false;
    }
  }

  Future<String> getDayIdFromFirebase(String dayCode) async {
    try {
      final dayDoc =
          await _db.collection('Days').where('code', isEqualTo: dayCode).get();
      if (dayDoc.docs.isEmpty) {
        return '';
      }

      final day = Day.fromDocument(dayDoc.docs.first.data());
      return day.id;
    } catch (ex) {
      _logger.severe(ex.toString());
      return '';
    }
  }

  Future<Day?> getDayByCodeFromFirebase(String dayCode) async {
    try {
      final dayDoc =
          await _db.collection('Days').where('code', isEqualTo: dayCode).get();
      if (dayDoc.docs.isEmpty) {
        return null;
      }

      return Day.fromDocument(dayDoc.docs.first.data());
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
            hasUploaded: false,
          ),
        );

        moment.nickname = participant.nickname;
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

        for (var moment in moments) {
          final participantDoc = await getParticipantsFromFirebase(dayId);
          final participant = participantDoc.firstWhere(
            (element) => element.uid == moment.uploadedBy,
            orElse: () => Participant(
              uid: '',
              role: '',
              nickname: '',
              fcmToken: '',
              hasUploaded: false,
            ),
          );
          moment.nickname = participant.nickname;
        }
        return moments;
      },
    );
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
      if (dayId.isEmpty) {
        return;
      }

      final currentUid = _authService.getCurrentUid();
      final likeDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Moments')
          .doc(imageId)
          .collection('Likes')
          .doc(currentUid)
          .get();

      if (likeDoc.exists) {
        // User has already voted the image, so we remove the like
        await likeDoc.reference.delete();

        final momentDoc = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Moments')
            .doc(imageId)
            .get();

        if (!momentDoc.exists) return;

        final moment = Moment.fromDocument(momentDoc.data()!);
        moment.votes -= 1;

        await momentDoc.reference.update({'votes': moment.votes});
      } else {
        // User has not liked the image, so we add the like
        await _db
            .collection('Days')
            .doc(dayId)
            .collection('Moments')
            .doc(imageId)
            .collection('Likes')
            .doc(currentUid)
            .set({});

        final momentDoc = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Moments')
            .doc(imageId)
            .get();

        if (!momentDoc.exists) return;

        final moment = Moment.fromDocument(momentDoc.data()!);
        moment.votes += 1;

        await momentDoc.reference.update({'votes': moment.votes});
      }
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
}
