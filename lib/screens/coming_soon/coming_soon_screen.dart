import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../models/upcoming_item.dart';
import '../../state/app_state.dart';
import '../../widgets/shimmer_image.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  final Map<String, bool> _mutedMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final upcoming = appState.upcomingItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded,
                color: AppColors.netflixRed, size: 24),
            const SizedBox(width: 8),
            Text('Hot & Coming Soon', style: AppTypography.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications are up to date')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 90, top: 8),
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          final item = upcoming[index];
          final hasReminder = appState.hasReminder(item.id);
          final isMuted = _mutedMap[item.id] ?? true;

          return _buildUpcomingCard(context, item, hasReminder, isMuted, appState);
        },
      ),
    );
  }

  Widget _buildUpcomingCard(
    BuildContext context,
    UpcomingItem item,
    bool hasReminder,
    bool isMuted,
    AppState appState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Date Badge Column
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  item.monthBadge,
                  style: AppTypography.chip.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  item.dayBadge,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Right Content Body
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Teaser Preview Box
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ShimmerImage(
                        imageUrl: item.videoTeaserBackdrop,
                        height: 180,
                        width: double.infinity,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      // Gradient overlay
                      Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x99000000)],
                          ),
                        ),
                      ),
                      // Mute / Unmute Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(() {
                                _mutedMap[item.id] = !isMuted;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action row: Title & Remind Me
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.isOriginal)
                                    Text(
                                      'NETLIV ORIGINAL',
                                      style: AppTypography.chip.copyWith(
                                        color: AppColors.netflixRed,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.title,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Remind Me Button
                            InkWell(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                appState.toggleReminder(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 1),
                                    content: Text(
                                      hasReminder
                                          ? 'Reminder removed'
                                          : 'We will notify you when "${item.title}" releases!',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Column(
                                  children: [
                                    Icon(
                                      hasReminder
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_none_rounded,
                                      color: hasReminder
                                          ? AppColors.netflixRed
                                          : Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hasReminder ? 'Reminded' : 'Remind Me',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: hasReminder
                                            ? AppColors.netflixRed
                                            : AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Release Date text
                        Text(
                          item.releaseDateText,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Synopsis
                        Text(
                          item.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Genre tags
                        Wrap(
                          spacing: 6,
                          children: item.genres.map((g) {
                            return Text(
                              '• $g',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
