/// Festival data model for the bundled Hindu calendar.
class Festival {
  final String id;
  final String name;
  final String nameDevanagari;
  final DateTime date;
  final DateTime? endDate;
  final String deity;
  final String description;
  final String aartiTag;
  final String emoji;

  const Festival({
    required this.id,
    required this.name,
    required this.nameDevanagari,
    required this.date,
    this.endDate,
    required this.deity,
    required this.description,
    required this.aartiTag,
    required this.emoji,
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id'] as String,
      name: json['name'] as String,
      nameDevanagari: json['nameDevanagari'] as String,
      date: DateTime.parse(json['date'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      deity: json['deity'] as String,
      description: json['description'] as String,
      aartiTag: json['aartiTag'] as String,
      emoji: json['emoji'] as String,
    );
  }

  /// Whether this festival is active today (single-day or within a range).
  bool isActiveOn(DateTime day) {
    final dayOnly = DateTime(day.year, day.month, day.day);
    final startDay = DateTime(date.year, date.month, date.day);
    if (endDate != null) {
      final endDay = DateTime(endDate!.year, endDate!.month, endDate!.day);
      return !dayOnly.isBefore(startDay) && !dayOnly.isAfter(endDay);
    }
    return dayOnly == startDay;
  }

  /// Whether the festival is upcoming within the next [days] days.
  bool isUpcomingWithin(int days, {DateTime? from}) {
    final now = from ?? DateTime.now();
    final dayOnly = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(date.year, date.month, date.day);
    final diff = startDay.difference(dayOnly).inDays;
    return diff > 0 && diff <= days;
  }

  /// Days remaining until this festival.
  int daysUntil({DateTime? from}) {
    final now = from ?? DateTime.now();
    final dayOnly = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(date.year, date.month, date.day);
    return startDay.difference(dayOnly).inDays;
  }
}
