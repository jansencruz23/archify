class Participant {
  final String uid;
  final String role;
  final String nickname;
  final String? fcmToken;
  late bool hasUploaded;

  Participant({
    required this.uid,
    required this.role,
    required this.nickname,
    required this.fcmToken,
    required this.hasUploaded,
  });

  factory Participant.fromDocument(DocumentSnapshot data) {
    return Participant(
        uid: data['uid'],
        role: data['role'],
        nickname: data['nickname'],
        fcmToken: data['fcmToken'],
        hasUploaded: data['hasUploaded']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'nickname': nickname,
      'fcmToken': fcmToken,
      'hasUploaded': hasUploaded,
    };
  }
}
