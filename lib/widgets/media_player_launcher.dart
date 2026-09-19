import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/episode.dart';
import '../models/media_item.dart';
import '../screens/auth/subscription_plan_screen.dart';
import '../screens/player/full_video_player_screen.dart';
import '../state/app_state.dart';
import 'simulated_player_modal.dart';

/// Plays [item]'s real uploaded video file full-screen when one exists,
/// falling back to the [SimulatedPlayerModal] mock for items without one.
/// If the item is marked as paid/premium and the user does not have an active
/// subscription, opens a subscription paywall modal.
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
  final appState = context.read<AppState>();

  // Check if content requires active subscription
  if (item.isPaid && !appState.hasActiveSubscription) {
    _showPaywallSheet(context, item);
    return Future.value();
  }

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

void _showPaywallSheet(BuildContext context, MediaItem item) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161616),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Lock Icon with glowing background
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.netflixRed.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.netflixRed.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.netflixRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Subscribe to Watch',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${item.title} requires an active VIP / Premium plan. Subscribe or renew your membership to unlock full HD streaming and unlimited downloads.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFB3B3B3),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Upgrade / Subscribe Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionPlanScreen(isOnboarding: false),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.netflixRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'View Plans & Unlock',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Maybe Later',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
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

