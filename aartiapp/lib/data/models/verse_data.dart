class VerseData {
  final String label;
  final List<String> lines;
  final List<String> transliteration;
  final List<String> meanings;
  final List<String> gujarati;

  const VerseData({
    required this.label,
    required this.lines,
    required this.transliteration,
    required this.meanings,
    this.gujarati = const [],
  });

  /// Deserialise from JSON map.
  factory VerseData.fromJson(Map<String, dynamic> json) {
    return VerseData(
      label: json['label'] as String,
      lines: _stringList(json['lines']),
      transliteration: _stringList(json['transliteration']),
      meanings: _stringList(json['meanings']),
      gujarati: _stringList(json['gujarati']),
    );
  }

  /// Serialise back to JSON.
  Map<String, dynamic> toJson() => {
        'label': label,
        'lines': lines,
        'transliteration': transliteration,
        'meanings': meanings,
        'gujarati': gujarati,
      };

  static List<String> _stringList(dynamic value) =>
      (value as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];
}
