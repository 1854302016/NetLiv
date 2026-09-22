class ShortVideo {
  final String id;
  final String title;
  final String subtitle;
  final String videoUrl;
  final String thumbnailUrl;
  final int likesCount;
  final int sharesCount;
  final int viewsCount;
  final int commentsCount;

  const ShortVideo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.likesCount = 1420,
    this.sharesCount = 340,
    this.viewsCount = 12500,
    this.commentsCount = 24,
  });

  factory ShortVideo.fromJson(Map<String, dynamic> json) {
    return ShortVideo(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      likesCount: json['likesCount'] as int? ?? (json['likes_count'] as int? ?? 1420),
      sharesCount: json['sharesCount'] as int? ?? (json['shares_count'] as int? ?? 340),
      viewsCount: json['viewsCount'] as int? ?? (json['views_count'] as int? ?? 12500),
      commentsCount: json['commentsCount'] as int? ?? (json['comments_count'] as int? ?? 24),
    );
  }
}
