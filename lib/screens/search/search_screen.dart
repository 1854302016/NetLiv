import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../data/mock_data.dart';
import '../../models/media_item.dart';
import '../../widgets/shimmer_image.dart';
import '../../widgets/simulated_player_modal.dart';
import '../details/content_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  String _selectedGenre = 'All';

  final List<String> _genres = const [
    'All',
    'Sci-Fi',
    'Action',
    'Cyberpunk',
    'Mystery',
    'Thriller',
    'Original',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<MediaItem> get _filteredResults {
    return MockData.allItems.where((item) {
      final matchesQuery = _query.isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.genres.any(
              (g) => g.toLowerCase().contains(_query.toLowerCase())) ||
          item.cast.any(
              (c) => c.toLowerCase().contains(_query.toLowerCase()));

      final matchesGenre = _selectedGenre == 'All' ||
          item.genres
              .any((g) => g.toLowerCase() == _selectedGenre.toLowerCase()) ||
          (_selectedGenre == 'Original' && item.isOriginal);

      return matchesQuery && matchesGenre;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.netflixRed
                        : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: AppTypography.bodyLarge.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search movies, shows, genres...',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 22),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textMuted, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Quick Genre Filter Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenre == genre;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedGenre = genre;
                        });
                      },
                      labelStyle: AppTypography.chip.copyWith(
                        color: isSelected ? Colors.black : const Color(0xFFE5E5E5),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      selectedColor: Colors.white,
                      backgroundColor: const Color(0xFF191919),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF383838),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Results Content
            Expanded(
              child: _query.isEmpty && _selectedGenre == 'All'
                  ? _buildEmptyStateContent()
                  : _buildGridResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Searches Keywords
          Text('Popular Searches', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MockData.trendingKeywords.map((keyword) {
              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _searchController.text = keyword;
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          size: 14, color: AppColors.netflixRed),
                      const SizedBox(width: 6),
                      Text(
                        keyword,
                        style: AppTypography.chip
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Top Searches List
          Text('Top Matches Today', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MockData.topTenToday.take(5).length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = MockData.topTenToday[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ContentDetailsScreen(item: item),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      ShimmerImage(
                        imageUrl: item.backdropUrl,
                        width: 90,
                        height: 54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.titleMedium
                                  .copyWith(fontSize: 13.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.genres.take(2).join(' • '),
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline_rounded,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          SimulatedPlayerModal.show(context, item);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildGridResults() {
    final results = _filteredResults;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('No titles found for "$_query"',
                style: AppTypography.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Try searching for another movie, actor, or genre',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return GestureDetector(
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
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 40))
            .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1));
      },
    );
  }
}
