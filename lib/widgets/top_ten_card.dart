import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/media_item.dart';
import '../screens/details/content_details_screen.dart';
import 'shimmer_image.dart';

class TopTenCard extends StatefulWidget {
  final MediaItem item;
  final int rank;

  const TopTenCard({
    super.key,
    required this.item,
    required this.rank,
  });

  @override
  State<TopTenCard> createState() => _TopTenCardState();
}

class _TopTenCardState extends State<TopTenCard>
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

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 125.0;
    const double cardHeight = 185.0;
    final heroTag = 'topten-${widget.item.id}';

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
          width: cardWidth + 52,
          height: cardHeight,
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Large Architectural Metallic Rank Number
              Positioned(
                left: -8,
                bottom: -20,
                child: Stack(
                  children: [
                    // Deep Drop Shadow
                    Text(
                      '${widget.rank}',
                      style: GoogleFonts.syne(
                        fontSize: 98,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -6.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6.0
                          ..color = Colors.black,
                      ),
                    ),
                    // Inner Fill (Deep Charcoal/Black)
                    Text(
                      '${widget.rank}',
                      style: GoogleFonts.syne(
                        fontSize: 98,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -6.0,
                        color: const Color(0xFF121212),
                      ),
                    ),
                    // Crisp Signature Netflix White Stroke Outline
                    Text(
                      '${widget.rank}',
                      style: GoogleFonts.syne(
                        fontSize: 98,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -6.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3.2
                          ..color = const Color(0xFFEFEFEF),
                      ),
                    ),
                  ],
                ),
              ),

              // Poster Card with Rim Lighting
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                width: cardWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: heroTag,
                      child: ShimmerImage(
                        imageUrl: widget.item.posterUrl,
                        width: cardWidth,
                        height: cardHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
