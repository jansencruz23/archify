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
  late String winnerId;

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
    this.winnerId = '',
  });

  // Firebase -> App
  factory Day.fromDocument(DocumentSnapshot data) {
    return Day(
      id: data['id'],
      hostId: data['hostId'],
      name: data['name'],
      description: data['description'],
      maxParticipants: data['maxParticipants'],
      votingDeadline: (data['votingDeadline'] as Timestamp).toDate(),
      code: data['code'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'],
      winnerId: data['winnerId'],
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
      'winnerId': winnerId,
    };
  }
}
