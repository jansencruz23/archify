class Participant {
  final String uid;
  final String role;
  final String nickname;
  final String? fcmToken;

  Participant(
      {required this.uid,
      required this.role,
      required this.nickname,
      required this.fcmToken});

  factory Participant.fromDocument(Map<String, dynamic> data) {
    return Participant(
        uid: data['uid'],
        role: data['role'],
        nickname: data['nickname'],
        fcmToken: data['fcmToken']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'nickname': nickname,
      'fcmToken': fcmToken
    };
  }
}
