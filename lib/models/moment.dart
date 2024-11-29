import 'package:cloud_firestore/cloud_firestore.dart';

class Moment {
  late String momentId;
  final String imageUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
  late int votes;
  late String nickname;
  late String dayName;

  Moment({
    required this.momentId,
    required this.imageUrl,
    required this.uploadedBy,
    required this.uploadedAt,
    this.votes = 0,
    this.dayName = '',
  });

  factory Moment.fromDocument(Map<String, dynamic> data) {
    return Moment(
      momentId: data['momentId'],
      imageUrl: data['imageUrl'],
      uploadedBy: data['uploadedBy'],
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      votes: data['votes'],
      dayName: data['dayName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'momentId': momentId,
      'imageUrl': imageUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
      'votes': votes,
      'dayName': dayName,
    };
  }
}
