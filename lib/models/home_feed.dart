import 'media_item.dart';

class GenreRow {
  final String genre;
  final List<MediaItem> items;

  const GenreRow({required this.genre, required this.items});

  factory GenreRow.fromJson(Map<String, dynamic> json) {
    return GenreRow(
      genre: json['genre'] as String,
      items: (json['items'] as List)
          .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HomeFeed {
  final List<MediaItem> banners;
  final List<MediaItem> topTen;
  final List<MediaItem> trending;
  final List<MediaItem> originals;
  final List<GenreRow> rowsByGenre;

  const HomeFeed({
    required this.banners,
    required this.topTen,
    required this.trending,
    required this.originals,
    required this.rowsByGenre,
  });

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    List<MediaItem> parseItems(String key) => (json[key] as List? ?? [])
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return HomeFeed(
      banners: (json['banners'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .where((e) => e['mediaItem'] != null)
          .map((e) => MediaItem.fromJson(e['mediaItem'] as Map<String, dynamic>))
          .toList(),
      topTen: parseItems('topTen'),
      trending: parseItems('trending'),
      originals: parseItems('originals'),
      rowsByGenre: (json['rowsByGenre'] as List? ?? [])
          .map((e) => GenreRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
