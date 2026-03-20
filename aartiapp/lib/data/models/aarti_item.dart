class AartiItem {
  final String title;
  final String devanagari;
  final String deity;
  final String duration;
  final String verses;
  final bool isBookmarked;
  final bool isOffline;

  const AartiItem({
    required this.title,
    required this.devanagari,
    required this.deity,
    required this.duration,
    required this.verses,
    this.isBookmarked = false,
    this.isOffline = false,
  });
}
