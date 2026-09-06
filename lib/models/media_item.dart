import 'episode.dart';

enum MediaType { movie, series }

class MediaItem {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String backdropUrl;
  final List<String> genres;
  final int releaseYear;
  final String ageRating;
  final String durationOrSeasons;
  final double matchScore; // e.g. 98.0 for 98% Match
  final MediaType type;
  final bool isOriginal;
  final bool isTrending;
  final int? topTenRank; // 1 to 10 if in Top 10
  final double? watchProgress; // 0.0 to 1.0 for Continue Watching
  final List<String> cast;
  final List<String> creators;
  final List<Episode>? episodes;
  final List<String>? tags;

  const MediaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genres,
    required this.releaseYear,
    required this.ageRating,
    required this.durationOrSeasons,
    required this.matchScore,
    required this.type,
    this.isOriginal = false,
    this.isTrending = false,
    this.topTenRank,
    this.watchProgress,
    this.cast = const [],
    this.creators = const [],
    this.episodes,
    this.tags,
  });
}
