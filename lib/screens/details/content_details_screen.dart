import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../data/mock_data.dart';
import '../../models/media_item.dart';
import '../../state/app_state.dart';
import '../../widgets/shimmer_image.dart';
import '../../widgets/simulated_player_modal.dart';

class ContentDetailsScreen extends StatefulWidget {
  final MediaItem item;

  const ContentDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<ContentDetailsScreen> createState() => _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends State<ContentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSynopsisExpanded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  int _selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.item.type == MediaType.series ? 4 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _simulateDownload() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isDownloaded(widget.item.id)) {
      appState.removeDownload(widget.item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from Downloads')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.1;
    });

    for (int i = 2; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _downloadProgress = i / 10.0;
      });
    }

    if (mounted) {
      setState(() {
        _isDownloading = false;
      });
      appState.toggleDownload(widget.item);
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Downloaded "${widget.item.title}" for offline viewing',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showShareSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Share "${widget.item.title}"',
                    style: AppTypography.titleMedium),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareIcon(Icons.link_rounded, 'Copy Link', () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    }),
                    _buildShareIcon(Icons.message_rounded, 'Messages', () {
                      Navigator.pop(context);
                    }),
                    _buildShareIcon(Icons.share_rounded, 'More', () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final inList = appState.isInMyList(widget.item.id);
    final isDownloaded = appState.isDownloaded(widget.item.id);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Backdrop Sliver AppBar
          SliverAppBar(
            expandedHeight: size.height * 0.44,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.cast_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connected to TV')),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'media-${widget.item.id}',
                    child: ShimmerImage(
                      imageUrl: widget.item.backdropUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark Multi-stop Gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroOverlayGradient,
                    ),
                  ),
                  // Centered Play Button Overlay
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        SimulatedPlayerModal.show(context, widget.item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.netflixRed,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Meta Info & Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NetLiv Original Badge
                  if (widget.item.isOriginal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.netflixRed,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'NETLIV',
                            style: GoogleFonts.bebasNeue(
                              color: Colors.white,
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ORIGINAL',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 8.5,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Title
                  Text(
                    widget.item.title,
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Metadata Badges Row: Match %, Year, Age, Duration, 4K, HDR
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Match Score
                      Text(
                        '${widget.item.matchScore.toStringAsFixed(0)}% Match',
                        style: AppTypography.chip.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text('${widget.item.releaseYear}',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      // Age Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          widget.item.ageRating,
                          style: AppTypography.chip.copyWith(fontSize: 10),
                        ),
                      ),
                      Text(widget.item.durationOrSeasons,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      // 4K Ultra HD badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textMuted),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '4K Ultra HD',
                          style: AppTypography.chip.copyWith(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // Dolby Atmos badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textMuted),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Dolby Atmos',
                          style: AppTypography.chip.copyWith(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Large Full-Width Play Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        SimulatedPlayerModal.show(context, widget.item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded,
                          size: 26, color: Colors.black),
                      label: Text(
                        'Play',
                        style: AppTypography.button.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Full-Width Download Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _simulateDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      icon: _isDownloading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                value: _downloadProgress,
                                strokeWidth: 2.5,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(AppColors.netflixRed),
                              ),
                            )
                          : Icon(
                              isDownloaded
                                  ? Icons.download_done_rounded
                                  : Icons.download_rounded,
                              size: 22,
                              color: isDownloaded
                                  ? AppColors.netflixRed
                                  : Colors.white,
                            ),
                      label: Text(
                        _isDownloading
                            ? 'Downloading (${(_downloadProgress * 100).toInt()}%)'
                            : (isDownloaded ? 'Downloaded' : 'Download'),
                        style: AppTypography.button.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Synopsis with Expandable "Read More"
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSynopsisExpanded = !_isSynopsisExpanded;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.description,
                          maxLines: _isSynopsisExpanded ? null : 3,
                          overflow: _isSynopsisExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isSynopsisExpanded ? 'Show less' : 'Read more',
                          style: AppTypography.chip.copyWith(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Starring / Creators
                  if (widget.item.cast.isNotEmpty) ...[
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Starring: ',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textMuted),
                          ),
                          TextSpan(
                            text: widget.item.cast.join(', '),
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (widget.item.creators.isNotEmpty) ...[
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Creators: ',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textMuted),
                          ),
                          TextSpan(
                            text: widget.item.creators.join(', '),
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action Icons Bar: My List, Rate, Share
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // My List Button
                        _buildActionIcon(
                          icon: inList
                              ? Icons.check_rounded
                              : Icons.add_rounded,
                          label: 'My List',
                          color: inList ? AppColors.netflixRed : Colors.white,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            appState.toggleMyList(widget.item);
                          },
                        ),
                        // Rate Button
                        _buildActionIcon(
                          icon: Icons.thumb_up_alt_outlined,
                          label: 'Rate',
                          color: Colors.white,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you for rating!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        // Share Button
                        _buildActionIcon(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          color: Colors.white,
                          onTap: _showShareSheet,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 28),

                  // Tab Bar: Episodes (if series), More Like This, Trailers, Cast
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: AppTypography.chip.copyWith(fontSize: 12.5),
                    tabs: [
                      if (widget.item.type == MediaType.series)
                        const Tab(text: 'EPISODES'),
                      const Tab(text: 'MORE LIKE THIS'),
                      const Tab(text: 'TRAILERS'),
                      const Tab(text: 'CAST'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Tab Content Sliver
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildSelectedTabContent(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final int index = _tabController.index;
        if (widget.item.type == MediaType.series) {
          switch (index) {
            case 0:
              return _buildEpisodesSection();
            case 1:
              return _buildMoreLikeThisSection();
            case 2:
              return _buildTrailersSection();
            case 3:
              return _buildCastSection();
            default:
              return const SizedBox.shrink();
          }
        } else {
          switch (index) {
            case 0:
              return _buildMoreLikeThisSection();
            case 1:
              return _buildTrailersSection();
            case 2:
              return _buildCastSection();
            default:
              return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget _buildEpisodesSection() {
    final episodes = widget.item.episodes ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Season Dropdown Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedSeason,
              dropdownColor: AppColors.surfaceElevated,
              style: AppTypography.chip.copyWith(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Season 1')),
                DropdownMenuItem(value: 2, child: Text('Season 2')),
                DropdownMenuItem(value: 3, child: Text('Season 3')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedSeason = val;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Episodes List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: episodes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final ep = episodes[index];
            return InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                SimulatedPlayerModal.show(context, widget.item);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Episode Thumbnail with Play Overlay
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ShimmerImage(
                              imageUrl: ep.thumbnailUrl,
                              width: 110,
                              height: 65,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Episode Title & Duration
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${ep.episodeNumber}. ${ep.title}',
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ep.duration,
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        // Download Icon
                        IconButton(
                          icon: const Icon(Icons.download_rounded,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Downloading Episode ${ep.episodeNumber}...'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Episode Synopsis
                    Text(
                      ep.synopsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoreLikeThisSection() {
    final related = MockData.allItems
        .where((item) => item.id != widget.item.id)
        .take(9)
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: related.length,
      itemBuilder: (context, index) {
        final rel = related[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ContentDetailsScreen(item: rel),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ShimmerImage(
              imageUrl: rel.posterUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailersSection() {
    return Column(
      children: [
        _buildTrailerCard('Official Teaser Trailer', '1m 45s', widget.item.backdropUrl),
        const SizedBox(height: 14),
        _buildTrailerCard('Final Cinematic Trailer', '2m 30s', widget.item.posterUrl),
      ],
    );
  }

  Widget _buildTrailerCard(String title, String duration, String imageUrl) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        SimulatedPlayerModal.show(context, widget.item);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ShimmerImage(
                  imageUrl: imageUrl,
                  height: 150,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 28),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                  Text(duration,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastSection() {
    final castList = widget.item.cast.isNotEmpty
        ? widget.item.cast
        : ['David Sterling', 'Elena Rostova', 'Kenji Sato', 'Aria Montgomery'];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: castList.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.borderSubtle),
      itemBuilder: (context, index) {
        final actor = castList[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceHighlight,
            child: Text(
              actor[0],
              style: AppTypography.titleMedium.copyWith(color: AppColors.primaryLight),
            ),
          ),
          title: Text(actor, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
          subtitle: Text(
            'Cast Member / Character',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: AppColors.textMuted),
        );
      },
    );
  }
}
