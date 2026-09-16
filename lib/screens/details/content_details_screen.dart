import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../data/mock_data.dart';
import '../../models/media_item.dart';
import '../../state/app_state.dart';
import '../../widgets/shimmer_image.dart';
import '../../widgets/simulated_player_modal.dart';
import '../genre/genre_browse_screen.dart';

const List<String> _kFriendAvatars = [
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1607346256330-dee7af15f7c5?w=200&auto=format&fit=crop&q=80',
];

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
                    _buildShareIcon(Icons.link_rounded, 'Copy Link', () async {
                      Navigator.pop(context);
                      await Clipboard.setData(
                        ClipboardData(text: 'https://netliv.app/title/${widget.item.id}'),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied to clipboard')),
                        );
                      }
                    }),
                    _buildShareIcon(Icons.groups_rounded, 'Watch Party', () {
                      Navigator.pop(context);
                      _showWatchPartySheet();
                    }),
                    _buildShareIcon(Icons.share_rounded, 'More', () {
                      Navigator.pop(context);
                      Share.share(
                        'Check out "${widget.item.title}" on NetLiv! https://netliv.app/title/${widget.item.id}',
                      );
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

  void _showRatingSheet(AppState appState) {
    HapticFeedback.lightImpact();
    int selectedStars = appState.getUserRating(widget.item.id) ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Rate "${widget.item.title}"', style: AppTypography.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.item.matchScore.toStringAsFixed(0)}% of viewers loved this',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isFilled = starValue <= selectedStars;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setSheetState(() => selectedStars = starValue);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                              color: AppColors.accentGold,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedStars == 0
                            ? null
                            : () {
                                appState.setUserRating(widget.item.id, selectedStars);
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Thanks for rating!')),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.netflixRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Submit Rating'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String get _watchPartyCode {
    final hash = widget.item.id.codeUnits.fold<int>(0, (a, b) => a + b);
    return 'NETLIV-${(1000 + hash * 37) % 9000 + 1000}';
  }

  void _showWatchPartySheet() {
    HapticFeedback.lightImpact();
    final invited = <String>{};

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded, color: AppColors.netflixRed, size: 24),
                        const SizedBox(width: 10),
                        Text('Watch Party', style: AppTypography.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Watch "${widget.item.title}" together, perfectly in sync.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Room Code', style: AppTypography.bodySmall),
                              const SizedBox(height: 2),
                              Text(_watchPartyCode,
                                  style: AppTypography.titleMedium.copyWith(letterSpacing: 1.2)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: _watchPartyCode));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Room code copied')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Invite Friends', style: AppTypography.bodyMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 10,
                      children: _kFriendAvatars.map((url) {
                        final isInvited = invited.contains(url);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setSheetState(() {
                              isInvited ? invited.remove(url) : invited.add(url);
                            });
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isInvited ? AppColors.netflixRed : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: ShimmerImage(
                                  imageUrl: url,
                                  width: 48,
                                  height: 48,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              if (isInvited)
                                const Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: CircleAvatar(
                                    radius: 9,
                                    backgroundColor: AppColors.netflixRed,
                                    child: Icon(Icons.check_rounded, size: 12, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          HapticFeedback.heavyImpact();
                          SimulatedPlayerModal.show(
                            context,
                            widget.item,
                            isWatchParty: true,
                            partyAvatars: invited.toList(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.netflixRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Watch Party'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                  const SizedBox(height: 12),

                  // Tappable Genre Chips -> Genre Browse Grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.item.genres.map((genre) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GenreBrowseScreen(genre: genre),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            genre,
                            style: AppTypography.chip.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Audience Social Proof
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.netflixRed, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.item.matchScore.toStringAsFixed(0)}% of viewers loved this',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
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
                          icon: appState.getUserRating(widget.item.id) != null
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          label: appState.getUserRating(widget.item.id) != null
                              ? '${appState.getUserRating(widget.item.id)} / 5'
                              : 'Rate',
                          color: appState.getUserRating(widget.item.id) != null
                              ? AppColors.accentGold
                              : Colors.white,
                          onTap: () => _showRatingSheet(appState),
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
