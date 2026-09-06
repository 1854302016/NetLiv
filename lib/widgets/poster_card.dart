import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/media_item.dart';
import '../screens/details/content_details_screen.dart';
import 'shimmer_image.dart';

class PosterCard extends StatefulWidget {
  final MediaItem item;
  final double width;
  final double height;
  final bool isLandscape;
  final String heroPrefix;
  final VoidCallback? onTap;

  const PosterCard({
    super.key,
    required this.item,
    this.width = 125,
    this.height = 185,
    this.isLandscape = false,
    this.heroPrefix = 'poster',
    this.onTap,
  });

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) =>
              ContentDetailsScreen(item: widget.item),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = '${widget.heroPrefix}-${widget.item.id}';

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Poster Image with Hero
                Hero(
                  tag: heroTag,
                  child: ShimmerImage(
                    imageUrl: widget.isLandscape
                        ? widget.item.backdropUrl
                        : widget.item.posterUrl,
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover,
                  ),
                ),

                // Bottom Dark Shadow Gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: widget.height * 0.45,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.cardOverlayGradient,
                    ),
                  ),
                ),

                // NetLiv Original Minimalist Badge
                if (widget.item.isOriginal && !widget.isLandscape)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.netflixRed,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                      child: Text(
                        'ORIGINAL',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),

                // Title Overlay for Landscape / Continue Watching Cards
                if (widget.isLandscape)
                  Positioned(
                    bottom: (widget.item.watchProgress != null) ? 14 : 10,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (widget.item.watchProgress != null)
                          Text(
                            '${(widget.item.watchProgress! * 100).toInt()}% watched',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),

                // Solid Rich Progress Bar
                if (widget.item.watchProgress != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3.5,
                      color: Colors.white12,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: widget.item.watchProgress!,
                          child: Container(
                            color: AppColors.netflixRed,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
