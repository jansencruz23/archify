import 'package:cloud_firestore/cloud_firestore.dart';

class JoinedDay {
  final String dayId;
  final DateTime date;

  JoinedDay({
    required this.dayId,
    required this.date,
  });

  factory JoinedDay.fromDocument(Map<String, dynamic> data) {
    return JoinedDay(
      dayId: data['dayId'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayId': dayId,
      'date': date,
    };
  }
}
