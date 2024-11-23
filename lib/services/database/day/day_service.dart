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

  Future<void> sendImage(String imageUrl, String dayCode) async {
    try {
      final dayId = await getDayIdFromFirebase(dayCode);
      if (dayId.isEmpty) {
        return;
      }

      final moment = Moment(
        imageId: '',
        imageUrl: imageUrl,
        uploadedBy: _authService.getCurrentUid(),
        uploadedAt: DateTime.now(),
      );

      final docRef =
          _db.collection('Days').doc(dayId).collection('Moments').doc();
      moment.imageId = docRef.id;

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
}
