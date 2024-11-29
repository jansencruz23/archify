import 'package:cloud_firestore/cloud_firestore.dart';

class JoinedDay {
  final String dayId;
  final DateTime date;
  late bool hasWinner;

  JoinedDay({
    required this.dayId,
    required this.date,
    this.hasWinner = false,
  });

  factory JoinedDay.fromDocument(Map<String, dynamic> data) {
    return JoinedDay(
      dayId: data['dayId'],
      date: (data['date'] as Timestamp).toDate(),
      hasWinner: data['hasWinner'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayId': dayId,
      'date': date,
      'hasWinner': hasWinner,
    };
  }
}