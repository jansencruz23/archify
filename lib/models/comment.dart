import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  late String commentId;
  final String dayId;
  final String uid;
  final DateTime date;
  final String content;

  Comment({
    required this.commentId,
    required this.dayId,
    required this.uid,
    required this.date,
    required this.content,
  });

  factory Comment.fromDocument(Map<String, dynamic> data) {
    return Comment(
      commentId: data['commentId'],
      dayId: data['momentId'],
      uid: data['uid'],
      date: (data['date'] as Timestamp).toDate(),
      content: data['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'momentId': dayId,
      'uid': uid,
      'date': date,
      'content': content,
    };
  }
}
