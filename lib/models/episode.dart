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
}
