import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';

class DownloadedItem {
  final MediaItem mediaItem;
  final String localFilePath;
  final int fileSizeBytes;
  final DateTime downloadedAt;

  const DownloadedItem({
    required this.mediaItem,
    required this.localFilePath,
    required this.fileSizeBytes,
    required this.downloadedAt,
  });

  String get formattedSize {
    if (fileSizeBytes <= 0) return '0 MB';
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'id': mediaItem.id,
        'title': mediaItem.title,
        'description': mediaItem.description,
        'posterUrl': mediaItem.posterUrl,
        'backdropUrl': mediaItem.backdropUrl,
        'genres': mediaItem.genres,
        'releaseYear': mediaItem.releaseYear,
        'ageRating': mediaItem.ageRating,
        'durationOrSeasons': mediaItem.durationOrSeasons,
        'matchScore': mediaItem.matchScore,
        'type': mediaItem.type.name,
        'isOriginal': mediaItem.isOriginal,
        'isTrending': mediaItem.isTrending,
        'localFilePath': localFilePath,
        'fileSizeBytes': fileSizeBytes,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory DownloadedItem.fromJson(Map<String, dynamic> json) {
    final mediaItem = MediaItem(
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
    );
    return DownloadedItem(
      mediaItem: mediaItem,
      localFilePath: json['localFilePath'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      downloadedAt: json['downloadedAt'] != null
          ? DateTime.tryParse(json['downloadedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class DownloadService {
  static const String _prefKeyDownloads = 'netliv_offline_downloads';
  static final Map<String, double> _activeDownloads = {};
  static final StreamController<Map<String, double>> _progressController =
      StreamController<Map<String, double>>.broadcast();

  static Stream<Map<String, double>> get progressStream =>
      _progressController.stream;

  static double? getProgress(String mediaId) => _activeDownloads[mediaId];

  static Future<Directory> _getDownloadDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/netliv_downloads');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<List<DownloadedItem>> getDownloadedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyDownloads);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      final items = <DownloadedItem>[];
      for (final item in list) {
        final downloaded = DownloadedItem.fromJson(item as Map<String, dynamic>);
        if (await File(downloaded.localFilePath).exists()) {
          items.add(downloaded);
        }
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isDownloaded(String mediaId) async {
    final items = await getDownloadedItems();
    return items.any((d) => d.mediaItem.id == mediaId);
  }

  static Future<String?> getLocalPath(String mediaId) async {
    final items = await getDownloadedItems();
    final match = items.where((d) => d.mediaItem.id == mediaId).firstOrNull;
    return match?.localFilePath;
  }

  static Future<void> downloadItem(
    MediaItem item, {
    Function(double progress)? onProgress,
  }) async {
    final videoUrl = item.videoUrl;
    final dir = await _getDownloadDir();
    final filePath = '${dir.path}/${item.id}.mp4';
    final file = File(filePath);

    _activeDownloads[item.id] = 0.01;
    _progressController.add(Map.from(_activeDownloads));
    onProgress?.call(0.01);

    try {
      if (videoUrl != null &&
          videoUrl.isNotEmpty &&
          (videoUrl.startsWith('http://') || videoUrl.startsWith('https://'))) {
        final request = http.Request('GET', Uri.parse(videoUrl));
        final response = await http.Client().send(request);
        final totalLength = response.contentLength ?? 15 * 1024 * 1024;

        int received = 0;
        final sink = file.openWrite();

        await response.stream.listen((chunk) {
          sink.add(chunk);
          received += chunk.length;
          final progress = (received / totalLength).clamp(0.0, 0.99);
          _activeDownloads[item.id] = progress;
          _progressController.add(Map.from(_activeDownloads));
          onProgress?.call(progress);
        }).asFuture();

        await sink.flush();
        await sink.close();
      } else {
        final sink = file.openWrite();
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          sink.add(utf8.encode('NetLiv encrypted chunk $i\n'));
          final progress = i / 10.0;
          _activeDownloads[item.id] = progress;
          _progressController.add(Map.from(_activeDownloads));
          onProgress?.call(progress);
        }
        await sink.flush();
        await sink.close();
      }

      final size = await file.length();
      final downloadedItem = DownloadedItem(
        mediaItem: item,
        localFilePath: filePath,
        fileSizeBytes: size > 0 ? size : 45 * 1024 * 1024,
        downloadedAt: DateTime.now(),
      );

      final currentList = await getDownloadedItems();
      currentList.removeWhere((d) => d.mediaItem.id == item.id);
      currentList.insert(0, downloadedItem);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKeyDownloads,
        jsonEncode(currentList.map((d) => d.toJson()).toList()),
      );
    } catch (e) {
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      _activeDownloads.remove(item.id);
      _progressController.add(Map.from(_activeDownloads));
      onProgress?.call(1.0);
    }
  }

  static Future<void> deleteDownload(String mediaId) async {
    final items = await getDownloadedItems();
    final match = items.where((d) => d.mediaItem.id == mediaId).firstOrNull;
    if (match != null) {
      final file = File(match.localFilePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      items.removeWhere((d) => d.mediaItem.id == mediaId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKeyDownloads,
        jsonEncode(items.map((d) => d.toJson()).toList()),
      );
    }
  }
}
