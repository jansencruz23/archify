import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Day {
  final String id;
  final String hostId;
  final String name;
  final String description;
  final int maxParticipants;
  final DateTime votingDeadline;
  final String code;

  Day({
    required this.id,
    required this.hostId,
    required this.name,
    required this.description,
    required this.maxParticipants,
    required this.votingDeadline,
    required this.code,
  });

  set id(String id) {
    id = id;
  }

  // Firebase -> App
  factory Day.fromDocument(DocumentSnapshot doc) {
    return Day(
      id: doc['id'],
      hostId: doc['hostId'],
      name: doc['name'],
      description: doc['description'],
      maxParticipants: doc['maxParticipants'],
      votingDeadline: doc['votingDeadline'],
      code: doc['code'],
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
    };
  }
}
