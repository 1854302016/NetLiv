import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Pulsing "LIVE"-style badge with a simulated real-time viewer count,
/// derived deterministically from the item id so it stays stable per item.
class TrendingBadge extends StatelessWidget {
  final String itemId;
  final bool compact;

  const TrendingBadge({
    super.key,
    required this.itemId,
    this.compact = false,
  });

  int get _viewerCount {
    final hash = itemId.codeUnits.fold<int>(0, (a, b) => a + b);
    return 8200 + (hash * 137) % 42000;
  }

  String get _formattedViewers {
    final count = _viewerCount;
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.netflixRed.withOpacity(0.8), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.netflixRed,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
                duration: const Duration(milliseconds: 700),
                begin: 0.25,
              ),
          const SizedBox(width: 4),
          Text(
            compact ? _formattedViewers : '$_formattedViewers watching',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: compact ? 8.5 : 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
