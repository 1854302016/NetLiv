import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../models/media_item.dart';
import '../../state/app_state.dart';
import '../../widgets/media_player_launcher.dart';
import '../../widgets/shimmer_image.dart';
import '../details/content_details_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  int _selectedSegment = 0; // 0: My List, 1: Downloads
  String _filterType = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Library', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () => appState.setTabIndex(1),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Switcher (My List vs Downloads)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'My List (${appState.myList.length})',
                      isSelected: _selectedSegment == 0,
                      onTap: () => setState(() => _selectedSegment = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      title: 'Downloads (${appState.downloads.length})',
                      isSelected: _selectedSegment == 1,
                      onTap: () => setState(() => _selectedSegment = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Expanded(
            child: _selectedSegment == 0
                ? _buildMyListContent(context, appState)
                : _buildDownloadsContent(context, appState),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.netflixRed : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          title,
          style: AppTypography.chip.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMyListContent(BuildContext context, AppState appState) {
    List<MediaItem> items = appState.myList;
    if (_filterType == 'Movies') {
      items = items.where((i) => i.type == MediaType.movie).toList();
    } else if (_filterType == 'Shows') {
      items = items.where((i) => i.type == MediaType.series).toList();
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_outline_rounded,
                  size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('Your List is Empty', style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Explore movies and shows and tap the "+ My List" button to save them here.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => appState.setTabIndex(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.netflixRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Discover Blockbusters'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Sub-filter Row: All, Movies, TV Shows
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Movies'),
              const SizedBox(width: 8),
              _buildFilterChip('Shows'),
            ],
          ),
        ),

        // Grid of items
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90, top: 4),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ContentDetailsScreen(item: item),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ShimmerImage(
                        imageUrl: item.posterUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Delete / remove bookmark button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        appState.removeFromMyList(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed "${item.title}" from My List'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          _filterType = label;
        });
      },
      labelStyle: AppTypography.chip.copyWith(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 11,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceElevated,
      side: BorderSide(
        color: isSelected ? Colors.transparent : AppColors.borderSubtle,
      ),
    );
  }

  Widget _buildDownloadsContent(BuildContext context, AppState appState) {
    final downloads = appState.downloads;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Smart Downloads Setting Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings_suggest_rounded,
                            color: AppColors.netflixRed, size: 22),
                        const SizedBox(width: 8),
                        Text('Smart Downloads', style: AppTypography.titleMedium),
                      ],
                    ),
                    Switch.adaptive(
                      value: appState.smartDownloads,
                      activeColor: AppColors.netflixRed,
                      onChanged: (val) => appState.toggleSmartDownloads(val),
                    ),
                  ],
                ),
                Text(
                  'Automatically delete completed episodes and download the next one when connected to Wi-Fi.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Storage indicator bar
          Text('Device Storage', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: 18,
                    child: Container(color: AppColors.netflixRed),
                  ),
                  Expanded(
                    flex: 40,
                    child: Container(color: AppColors.surfaceHighlight),
                  ),
                  Expanded(
                    flex: 42,
                    child: Container(color: AppColors.border),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NetLiv: 3.4 GB  •  Other Apps: 42.1 GB',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'Free: 82.5 GB',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Downloaded Items List
          Text('Downloaded Items', style: AppTypography.titleMedium),
          const SizedBox(height: 12),

          if (downloads.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.cloud_download_outlined,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No downloaded videos yet', style: AppTypography.titleMedium),
                  const SizedBox(height: 4),
                  Text('Download your favorite shows to watch on the go.',
                      style: AppTypography.bodySmall),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: downloads.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = downloads[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ShimmerImage(
                          imageUrl: item.backdropUrl,
                          width: 100,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.titleMedium
                                  .copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.durationOrSeasons}  •  1.4 GB  •  4K',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      // Play Button
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill_rounded,
                            color: AppColors.primaryLight, size: 28),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          playMedia(context, item);
                        },
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.textMuted, size: 22),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          appState.removeDownload(item.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
