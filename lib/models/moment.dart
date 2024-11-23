import 'package:cloud_firestore/cloud_firestore.dart';

class Moment {
  late String imageId;
  final String imageUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int votes;
  late String nickname;

  Moment({
    required this.imageId,
    required this.imageUrl,
    required this.uploadedBy,
    required this.uploadedAt,
    this.votes = 0,
  });

  factory Moment.fromDocument(Map<String, dynamic> data) {
    return Moment(
      imageId: data['imageId'],
      imageUrl: data['imageUrl'],
      uploadedBy: data['uploadedBy'],
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      votes: data['votes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageId': imageId,
      'imageUrl': imageUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
      'votes': votes,
    };
  }
}
