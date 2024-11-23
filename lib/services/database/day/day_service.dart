import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/models/participant.dart';
import 'package:archify/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class DayService {
  final _db = FirebaseFirestore.instance;
  final _authService = AuthService();

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
  Future<void> startDayInFirebase(String dayCode, String nickname) async {
    try {
      final day = await getDayByCodeFromFirebase(dayCode);
      if (day == null) {
        return;
      }
      final currentUserId = _authService.getCurrentUid();
      final participant = Participant(
        uid: currentUserId,
        role: day.hostId == currentUserId ? 'host' : 'participant',
        nickname: nickname,
      );
      await _db
          .collection('Days')
          .doc(day.id)
          .collection('Participants')
          .doc(currentUserId)
          .set(participant.toMap());
    } catch (ex) {
      logger.severe(ex.toString());
    }
  }

  Future<void> sendImageToFirebase(String imageUrl, String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) {
        return;
      }

      final moment = Moment(
        momentId: '',
        imageUrl: imageUrl,
        uploadedBy: _authService.getCurrentUid(),
        uploadedAt: DateTime.now(),
      );

      final docRef =
          _db.collection('Days').doc(dayId).collection('Moments').doc();
      moment.momentId = docRef.id;

      await docRef.set(moment.toMap());
    } catch (ex) {
      logger.severe(ex.toString());
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
      return day.status;
    } catch (ex) {
      logger.severe(ex.toString());
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
      logger.severe(ex.toString());
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
      logger.severe(ex.toString());
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
          orElse: () => Participant(uid: '', role: '', nickname: ''),
        );

        moment.nickname = participant.nickname;
      }

      return moments;
    } catch (ex) {
      logger.severe(ex.toString());
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
          .map((doc) => Participant.fromDocument(doc.data()))
          .toList();
      return participants;
    } catch (ex) {
      logger.severe(ex.toString());
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
        final moment = Moment.fromDocument(momentDoc.data()!);
        moment.votes += 1;

        await momentDoc.reference.update({'votes': moment.votes});
      }
    } catch (ex) {
      logger.severe(ex.toString());
    }
  }
}
