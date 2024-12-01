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
      return Day.fromDocument(dayDoc);
    } catch (ex) {
      _logger.severe(ex.toString());
      return null;
    }
  }

  // Start the day
  Future<void> startDayInFirebase(String dayCode, String nickname) async {
    try {
      final day = await getDayByCodeFromFirebase(dayCode);
      if (day == null) {
        return;
      }
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

      final participant = Participant.fromDocument(participantDoc);
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

      final day = Day.fromDocument(dayDoc.docs.first);

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

      final day = Day.fromDocument(dayDoc.docs.first);
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

      return Day.fromDocument(dayDoc.docs.first);
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

      final moments =
          momentsDoc.docs.map((doc) => Moment.fromDocument(doc)).toList();

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

  Future<List<Participant>> getParticipantsFromFirebase(String dayId) async {
    try {
      final participantsDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Participants')
          .get();

      final participants = participantsDoc.docs
          .map((doc) => Participant.fromDocument(doc))
          .toList();
      return participants;
    } catch (ex) {
      _logger.severe(ex.toString());
      return [];
    }
  }

  Future<void> likeImageInFirebase(String dayCode, String imageId) async {
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
        // User has already liked the image, so we remove the like
        await likeDoc.reference.delete();

        final momentDoc = await _db
            .collection('Days')
            .doc(dayId)
            .collection('Moments')
            .doc(imageId)
            .get();
        final moment = Moment.fromDocument(momentDoc);
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
        final moment = Moment.fromDocument(momentDoc);
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

      final participant = Participant.fromDocument(participantDoc);
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
        final moment = Moment.fromDocument(winner);
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
      final day = Day.fromDocument(dayDoc);
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

  Future<List<Comment>> getCommentsFromFirebase(String dayId) async {
    try {
      final commentsDoc = await _db
          .collection('Days')
          .doc(dayId)
          .collection('Comments')
          .orderBy('date', descending: true)
          .get();

      final comments =
          commentsDoc.docs.map((doc) => Comment.fromDocument(doc)).toList();

      for (var comment in comments) {
        final userDoc = await _db.collection('Users').doc(comment.uid).get();
        final user = userDoc.data();
        comment.profilePictureUrl = user?['pictureUrl'] ?? '';
      }

      return comments;
    } catch (ex) {
      _logger.severe(ex.toString());
      return [];
    }
  }
}
