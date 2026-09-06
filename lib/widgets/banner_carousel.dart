import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/media_item.dart';
import '../screens/details/content_details_screen.dart';
import '../state/app_state.dart';
import 'shimmer_image.dart';
import 'simulated_player_modal.dart';

class BannerCarousel extends StatefulWidget {
  final List<MediaItem> items;

  const BannerCarousel({
    super.key,
    required this.items,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage >= widget.items.length) {
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_pageController.hasClients && widget.items.isNotEmpty) {
        final nextPage = (_currentPage + 1) % widget.items.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    // Ensure _currentPage is always within bounds
    final safeIndex = _currentPage.clamp(0, widget.items.length - 1);
    final currentItem = widget.items[safeIndex];
    final size = MediaQuery.of(context).size;
    final bannerHeight = size.height * 0.65;

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        children: [
          // Main Hero Banner PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return GestureDetector(
                onTap: () => _openDetails(item),
                child: Hero(
                  tag: 'media-${item.id}',
                  child: ShimmerImage(
                    imageUrl: item.posterUrl,
                    height: bannerHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    overlay: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroOverlayGradient,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top Gradient Blend for Status Bar & App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Floating Glass Command Center Dock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildHeroGlassCommandCenter(currentItem),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGlassCommandCenter(MediaItem item) {
    final appState = Provider.of<AppState>(context);
    final inList = appState.isInMyList(item.id);
    final safeIndex = _currentPage.clamp(0, widget.items.length - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Original Studio / Exclusive Badge
          if (item.isOriginal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 10),
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

          // Blockbuster Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 18,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Genre tags & Spatial Audio Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.genres.take(3).join('   •   '),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.surface.withOpacity(0.8),
                ),
                child: Text(
                  '4K HDR',
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Modern Action Controls: Play Button & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // My List Button
              _buildActionButton(
                icon: inList ? Icons.check_rounded : Icons.add_rounded,
                label: inList ? 'Added' : 'My List',
                isActive: inList,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  appState.toggleMyList(item);
                },
              ),
              const SizedBox(width: 14),

              // Solid White Play Button with Tactile Shadow
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    SimulatedPlayerModal.show(context, item);
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 26,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Play',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Details / Info Button
              _buildActionButton(
                icon: Icons.info_outline_rounded,
                label: 'Details',
                isActive: false,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openDetails(item);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Minimalist Modern Page Indicator Capsules
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.items.length,
              (index) {
                final isCurrent = index == safeIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 3.5,
                  width: isCurrent ? 24 : 6,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.netflixRed
                        : const Color(0xFF444444),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF333333)
                : const Color(0xFF222222),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? AppColors.netflixRed
                  : const Color(0xFF3D3D3D),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.netflixRed : Colors.white,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive ? Colors.white : const Color(0xFFE5E5E5),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(MediaItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ContentDetailsScreen(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
