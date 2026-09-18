import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../screens/player/full_video_player_screen.dart';
import 'simulated_player_modal.dart';

/// Plays [item]'s real uploaded video file full-screen when one exists,
/// falling back to the [SimulatedPlayerModal] mock for items without one.
Future<void> playMedia(
  BuildContext context,
  MediaItem item, {
  bool isWatchParty = false,
  List<String> partyAvatars = const [],
}) {
  final videoUrl = item.videoUrl;
  if (videoUrl != null && videoUrl.isNotEmpty) {
    return FullVideoPlayerScreen.show(context, item);
  }

  return SimulatedPlayerModal.show(
    context,
    item,
    isWatchParty: isWatchParty,
    partyAvatars: partyAvatars,
  );
}
