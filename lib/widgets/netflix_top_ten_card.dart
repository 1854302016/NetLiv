import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/media_item.dart';
import '../screens/details/content_details_screen.dart';
import 'shimmer_image.dart';

/// Authentic Netflix Top 10 Card featuring the iconic hollow outlined rank numbers (1, 2, 3...)
/// overlapping the bottom-left edge of the poster, matching Image 1.
class NetflixTopTenCard extends StatefulWidget {
  final MediaItem item;
  final int rank;
  final VoidCallback? onTap;

  const NetflixTopTenCard({
    super.key,
    required this.item,
    required this.rank,
    this.onTap,
  });

  @override
  State<NetflixTopTenCard> createState() => _NetflixTopTenCardState();
}

class _NetflixTopTenCardState extends State<NetflixTopTenCard> {
  bool _isPressed = false;

  void _handleTap() {
    HapticFeedback.selectionClick();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 320),
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
    const double cardWidth = 125.0;
    const double cardHeight = 185.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          width: cardWidth + 36,
          height: cardHeight,
          margin: const EdgeInsets.only(right: 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Poster Card Container
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: cardWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ShimmerImage(
                        imageUrl: widget.item.posterUrl,
                        fit: BoxFit.cover,
                      ),

                      // NetLiv/Netflix Top-left badge if original
                      if (widget.item.isOriginal)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.netflixRed,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'N',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                      // Bottom gradient vignette
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Huge Authentic Netflix Hollow Outlined Rank Number
              Positioned(
                left: 0,
                bottom: -8,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      // Thick Black Back Drop for high contrast against background
                      Text(
                        '${widget.rank}',
                        style: GoogleFonts.syne(
                          fontSize: 84,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -6.0,
                          height: 1.0,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 9.0
                            ..color = Colors.black,
                        ),
                      ),
                      // Solid Black Fill inside the numeral
                      Text(
                        '${widget.rank}',
                        style: GoogleFonts.syne(
                          fontSize: 84,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -6.0,
                          height: 1.0,
                          color: const Color(0xFF101010),
                        ),
                      ),
                      // Sharp White Outline Stroke (The OG Netflix Top 10 look!)
                      Text(
                        '${widget.rank}',
                        style: GoogleFonts.syne(
                          fontSize: 84,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -6.0,
                          height: 1.0,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3.2
                            ..strokeCap = StrokeCap.round
                            ..strokeJoin = StrokeJoin.round
                            ..color = const Color(0xFFF5F5F5),
                        ),
                      ),
                    ],
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
