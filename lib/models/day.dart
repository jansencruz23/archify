import 'package:cloud_firestore/cloud_firestore.dart';

class Day {
  late String id;
  final String hostId;
  final String name;
  final String description;
  final int maxParticipants;
  final DateTime votingDeadline;
  final String code;
  final DateTime createdAt;
  final bool status;

  Day({
    required this.id,
    required this.hostId,
    required this.name,
    required this.description,
    required this.maxParticipants,
    required this.votingDeadline,
    required this.code,
    required this.createdAt,
    required this.status,
  });

  // Firebase -> App
  factory Day.fromDocument(DocumentSnapshot doc) {
    return Day(
      id: doc['id'],
      hostId: doc['hostId'],
      name: doc['name'],
      description: doc['description'],
      maxParticipants: doc['maxParticipants'],
      votingDeadline: (doc['votingDeadline'] as Timestamp).toDate(),
      code: doc['code'],
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      status: doc['status'],
    );
  }

  // App -> Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hostId': hostId,
      'name': name,
      'description': description,
      'maxParticipants': maxParticipants,
      'votingDeadline': votingDeadline,
      'code': code,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
