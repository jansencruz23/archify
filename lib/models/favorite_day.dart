import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteDay {
  final String dayId;
  final DateTime date;

  FavoriteDay({
    required this.dayId,
    required this.date,
  });

  factory FavoriteDay.fromDocument(Map<String, dynamic> data) {
    return FavoriteDay(
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
