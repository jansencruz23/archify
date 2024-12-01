import 'package:archify/models/moment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String bio;
  final String pictureUrl;
  final bool isNew;
  late List<Moment> favoriteDays;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    required this.pictureUrl,
    required this.isNew,
    List<Moment>? favoriteDays,
  }) : favoriteDays = favoriteDays ?? [];

  // Firebase -> App
  factory UserProfile.fromDocument(Map<String, dynamic> doc) {
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      username: doc['username'],
      bio: doc['bio'],
      pictureUrl: doc['pictureUrl'],
      isNew: doc['isNew'],
    );
  }

  // App -> Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'pictureUrl': pictureUrl,
      'isNew': isNew,
    };
  }
}
