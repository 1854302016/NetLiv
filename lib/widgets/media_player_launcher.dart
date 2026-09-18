import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/media_item.dart';
import '../screens/player/full_video_player_screen.dart';
import 'simulated_player_modal.dart';

/// Plays [item]'s real uploaded video file full-screen when one exists,
/// falling back to the [SimulatedPlayerModal] mock for items without one.
Future<void> playMedia(
  BuildContext context,
  MediaItem item, {
  String? videoUrl,
  String? title,
  String? subtitle,
  int? episodeIndex,
  List<Episode>? episodes,
  bool isWatchParty = false,
  List<String> partyAvatars = const [],
}) {
  final targetVideoUrl = videoUrl ?? item.videoUrl;
  if (targetVideoUrl != null && targetVideoUrl.isNotEmpty) {
    return FullVideoPlayerScreen.show(
      context,
      item,
      videoUrl: targetVideoUrl,
      title: title,
      subtitle: subtitle,
      episodeIndex: episodeIndex,
      episodes: episodes,
    );
  }

  return SimulatedPlayerModal.show(
    context,
    item,
    isWatchParty: isWatchParty,
    partyAvatars: partyAvatars,
  );
}

/// Plays a specific episode of a series item.
Future<void> playEpisode(
  BuildContext context,
  MediaItem item, {
  required int episodeIndex,
}) {
  final episodes = item.episodes ?? [];
  if (episodeIndex >= 0 && episodeIndex < episodes.length) {
    final ep = episodes[episodeIndex];
    final epVideoUrl = ep.videoUrl?.isNotEmpty == true ? ep.videoUrl : item.videoUrl;
    return playMedia(
      context,
      item,
      videoUrl: epVideoUrl,
      title: item.title,
      subtitle: 'S${ep.seasonNumber}:E${ep.episodeNumber} • ${ep.title}',
      episodeIndex: episodeIndex,
      episodes: episodes,
    );
  }
  return playMedia(context, item);
}

