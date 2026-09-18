class ShortVideo {
  final String id;
  final String title;
  final String subtitle;
  final String videoUrl;
  final String thumbnailUrl;

  const ShortVideo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  factory ShortVideo.fromJson(Map<String, dynamic> json) {
    return ShortVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}
