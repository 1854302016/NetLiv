class Episode {
  final int episodeNumber;
  final int seasonNumber;
  final String title;
  final String duration;
  final String synopsis;
  final String thumbnailUrl;

  const Episode({
    required this.episodeNumber,
    required this.seasonNumber,
    required this.title,
    required this.duration,
    required this.synopsis,
    required this.thumbnailUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episodeNumber'] as int,
      seasonNumber: json['seasonNumber'] as int,
      title: json['title'] as String,
      duration: json['duration'] as String,
      synopsis: json['synopsis'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}
