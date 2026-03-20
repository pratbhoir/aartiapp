import 'verse_data.dart';

class AartiItem {
  final String id;
  final String title;
  final String devanagari;
  final String deity;
  final String duration;
  final String versesLabel; // e.g. "6 verses"
  final bool isBookmarked;
  final bool isOffline;
  final List<String> tags;
  final List<VerseData> verses; // actual verse content
  final String audioUrl;

  /// Default audio URL for all aartis.
  static const String defaultAudioUrl =
      'https://smt.rajresortarnala.com/aarti/aarti01.mp3';

  const AartiItem({
    required this.id,
    required this.title,
    required this.devanagari,
    required this.deity,
    required this.duration,
    this.versesLabel = '',
    this.isBookmarked = false,
    this.isOffline = false,
    this.tags = const [],
    this.verses = const [],
    this.audioUrl = defaultAudioUrl,
  });

  /// Deserialise from JSON map (aarti_catalog.json schema).
  factory AartiItem.fromJson(Map<String, dynamic> json) {
    final versesList = (json['verses'] as List<dynamic>?) ?? [];
    return AartiItem(
      id: json['id'] as String,
      title: json['title'] as String,
      devanagari: json['devanagari'] as String,
      deity: json['deity'] as String,
      duration: json['duration'] as String,
      versesLabel: '${versesList.length} verses',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      verses: versesList
          .map((v) => VerseData.fromJson(v as Map<String, dynamic>))
          .toList(),
      audioUrl: (json['audioUrl'] as String?) ?? defaultAudioUrl,
    );
  }

  /// Serialise back to JSON (for user-created aartis / future API sync).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'devanagari': devanagari,
        'deity': deity,
        'duration': duration,
        'tags': tags,
        'verses': verses.map((v) => v.toJson()).toList(),
        'audioUrl': audioUrl,
      };

  AartiItem copyWith({
    String? id,
    String? title,
    String? devanagari,
    String? deity,
    String? duration,
    String? versesLabel,
    bool? isBookmarked,
    bool? isOffline,
    List<String>? tags,
    List<VerseData>? verses,
    String? audioUrl,
  }) {
    return AartiItem(
      id: id ?? this.id,
      title: title ?? this.title,
      devanagari: devanagari ?? this.devanagari,
      deity: deity ?? this.deity,
      duration: duration ?? this.duration,
      versesLabel: versesLabel ?? this.versesLabel,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isOffline: isOffline ?? this.isOffline,
      tags: tags ?? this.tags,
      verses: verses ?? this.verses,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
