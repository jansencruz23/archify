class Participant {
  final String uid;
  final String role;
  final String nickname;

  Participant({
    required this.uid,
    required this.role,
    required this.nickname,
  });

  factory Participant.fromDocument(Map<String, dynamic> data) {
    return Participant(
      uid: data['uid'],
      role: data['role'],
      nickname: data['nickname'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'nickname': nickname,
    };
  }
}
