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
  final bool isPaid;
  final int? topTenRank; // 1 to 10 if in Top 10
  final double? watchProgress; // 0.0 to 1.0 for Continue Watching
  final List<String> cast;
  final List<String> creators;
  final List<Episode>? episodes;
  final List<String>? tags;
  final String? videoUrl;

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
    this.isPaid = true,
    this.topTenRank,
    this.watchProgress,
    this.cast = const [],
    this.creators = const [],
    this.episodes,
    this.tags,
    this.videoUrl,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final episodesJson = json['episodes'] as List?;
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      posterUrl: json['posterUrl'] as String,
      backdropUrl: json['backdropUrl'] as String,
      genres: List<String>.from(json['genres'] as List? ?? []),
      releaseYear: json['releaseYear'] as int,
      ageRating: json['ageRating'] as String,
      durationOrSeasons: json['durationOrSeasons'] as String,
      matchScore: (json['matchScore'] as num).toDouble(),
      type: json['type'] == 'series' ? MediaType.series : MediaType.movie,
      isOriginal: json['isOriginal'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isPaid: json['is_paid'] as bool? ?? json['isPaid'] as bool? ?? true,
      topTenRank: json['topTenRank'] as int?,
      cast: List<String>.from(json['cast'] as List? ?? []),
      creators: List<String>.from(json['creators'] as List? ?? []),
      episodes: episodesJson != null && episodesJson.isNotEmpty
          ? episodesJson.map((e) => Episode.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      videoUrl: json['videoUrl'] as String?,
    );
  }
}
