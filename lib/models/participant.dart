class Participant {
  final String uid;
  final String role;
  final String nickname;
  final String? fcmToken;
  final String avatar;
  late bool hasUploaded;

  Participant({
    required this.uid,
    required this.role,
    required this.nickname,
    required this.fcmToken,
    required this.avatar,
    required this.hasUploaded,
  });

  factory Participant.fromDocument(Map<String, dynamic> data) {
    return Participant(
      uid: data['uid'],
      role: data['role'],
      nickname: data['nickname'],
      fcmToken: data['fcmToken'],
      hasUploaded: data['hasUploaded'],
      avatar: data['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'nickname': nickname,
      'fcmToken': fcmToken,
      'hasUploaded': hasUploaded,
      'avatar': avatar,
    };
  }
}
