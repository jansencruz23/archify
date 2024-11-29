class JoinedDay {
  final String dayId;
  final DateTime date;

  JoinedDay({
    required this.dayId,
    required this.date,
  });

  factory JoinedDay.fromDocument(Map<String, dynamic> json) {
    return JoinedDay(
      dayId: json['dayId'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayId': dayId,
      'date': date.toIso8601String(),
    };
  }
}
