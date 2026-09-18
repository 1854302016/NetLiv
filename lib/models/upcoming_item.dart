class UpcomingItem {
  final String id;
  final String title;
  final String description;
  final String releaseDateText; // e.g., "Coming Friday" or "November 14"
  final String monthBadge; // e.g. "NOV"
  final String dayBadge; // e.g. "14"
  final String videoTeaserBackdrop;
  final List<String> genres;
  final bool isOriginal;

  const UpcomingItem({
    required this.id,
    required this.title,
    required this.description,
    required this.releaseDateText,
    required this.monthBadge,
    required this.dayBadge,
    required this.videoTeaserBackdrop,
    required this.genres,
    this.isOriginal = true,
  });

  factory UpcomingItem.fromJson(Map<String, dynamic> json) {
    return UpcomingItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      releaseDateText: json['releaseDateText'] as String,
      monthBadge: json['monthBadge'] as String,
      dayBadge: json['dayBadge'] as String,
      videoTeaserBackdrop: json['videoTeaserBackdrop'] as String,
      genres: List<String>.from(json['genres'] as List? ?? []),
      isOriginal: json['isOriginal'] as bool? ?? true,
    );
  }
}
