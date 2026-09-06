import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// NetLiv signature luxury logo.
/// Combines a bespoke geometric cinema emblem with clean architectural typography.
/// Pure, authoritative, and distinctly modern — avoiding playful rainbow motifs.
class NetLivLogo extends StatelessWidget {
  final double fontSize;
  final bool showTagline;

  const NetLivLogo({
    super.key,
    this.fontSize = 24,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = fontSize * 0.85;

    final logoRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Architectural Monogram Emblem (Netflix Red Emblem)
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(iconSize * 0.28),
            border: Border.all(
              color: AppColors.netflixRed.withOpacity(0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.netflixRed.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle red core
              Container(
                width: iconSize * 0.45,
                height: iconSize * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.netflixRed.withOpacity(0.2),
                ),
              ),
              // Cinema Play Icon
              Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: iconSize * 0.6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Typography: NETLIV (Crisp White + Netflix Red)
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'NET',
                style: GoogleFonts.syne(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'LIV',
                style: GoogleFonts.syne(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: AppColors.netflixRed,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!showTagline) return logoRow;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoRow,
        const SizedBox(height: 6),
        Text(
          'STUDIO CINEMA STREAMING',
          style: GoogleFonts.inter(
            fontSize: fontSize * 0.36,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
